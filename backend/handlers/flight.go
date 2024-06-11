package handlers

import (
	"backend/inputs"
	"backend/repositories"
	"backend/responses"
	"backend/services"
	"backend/utils"
	"backend/utils/token"
	"encoding/json"
	"github.com/gin-gonic/gin"
	socketio "github.com/googollee/go-socket.io"
	"gorm.io/gorm"
	"log"
	"net/http"
	"strconv"
	"time"
)

// REST

type FlightHandler struct {
	flightService services.FlightServiceInterface
}

func GetFlightHandler(db *gorm.DB) *FlightHandler {
	flightRepository := repositories.NewFlightRepository(db)
	flightService := services.NewFlightService(flightRepository)
	return NewFlightHandler(flightService)
}

func NewFlightHandler(flightService services.FlightServiceInterface) *FlightHandler {
	return &FlightHandler{flightService}
}

func (h *FlightHandler) GetAll(c *gin.Context) {
	response := &Response{
		Message: "flight endpoint",
	}
	c.JSON(http.StatusOK, response)
}

// CreateFlight godoc
//
// @Summary	Create flight
// @Schemes
// @Description	create a new flight
// @Tags			flight
// @Accept			json
// @Produce		json
//
// @Param			flightInput	body		inputs.InputCreateFlight	true	"Message body"
// @Success		201				{object}	responses.ResponseFlight
// @Failure		400				{object}	Response
//
// @Router			/flights [post]
//
// @Security	BearerAuth
func (h *FlightHandler) Create(c *gin.Context) {
	var input inputs.InputCreateFlight
	err := c.ShouldBindJSON(&input)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract JSON body",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	userID, err := token.ExtractTokenID(c)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract user ID from token",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	newFlight, err := h.flightService.CreateFlight(input, userID)
	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	c.JSON(http.StatusCreated, newFlight)
}

// GetCurrentFlight godoc
//
// @Summary	Get current flight
// @Schemes
// @Description	get current flight
// @Tags			flight
// @Accept			json
// @Produce		json
//
// @Success		200				{object}	responses.ResponseFlight
// @Failure		400				{object}	Response
// @Failure		404				{object}	Response
//
// @Router			/flights/current [get]
//
// @Security	BearerAuth
func (h *FlightHandler) GetCurrentFlight(c *gin.Context) {
	userID, err := token.ExtractTokenID(c)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract user ID from token",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	currentFlight, err := h.flightService.GetCurrentFlight(userID)
	if err != nil {
		response := &Response{
			Message: err.Error(),
		}

		//TODO status can be different
		c.JSON(http.StatusNotFound, response)
		return
	}

	c.JSON(http.StatusOK, currentFlight)
}

// WEBSOCKET

type FlightSocketHandler struct {
	flightService  services.FlightServiceInterface
	socketIoServer *socketio.Server
	stopChans      map[string]chan struct{}
}

func GetFlightSocketHandler(db *gorm.DB, server *socketio.Server) *FlightSocketHandler {
	flightRepository := repositories.NewFlightRepository(db)
	flightService := services.NewFlightService(flightRepository)
	return NewFlightSocketHandler(flightService, server)

}

func NewFlightSocketHandler(flightService services.FlightServiceInterface, server *socketio.Server) *FlightSocketHandler {
	return &FlightSocketHandler{
		flightService:  flightService,
		socketIoServer: server,
		stopChans:      make(map[string]chan struct{}),
	}
}

func (h *FlightSocketHandler) CreateFlightSession(s socketio.Conn, flightId string) {
	log.Println("Flight session created")

	convertedFlightId, err := strconv.Atoi(flightId)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error extracting flight ID", err.Error())
		return
	}

	flight, err := h.flightService.GetFlight(convertedFlightId)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error getting flight", err.Error())
		return
	}

	s.Join(flightId)

	if flight.Status == "waiting_proposal_approval" {
		err = estimateAndBroadcastFlightTime(s, convertedFlightId, h.flightService, h.socketIoServer)
	}

	if flight.Status == "waiting_takeoff" || flight.Status == "in_progress" {
		h.startPilotPositionUpdate(s, flightId)
	}
}

func (h *FlightSocketHandler) MakeFlightPriceProposal(s socketio.Conn, msg string) error {
	userId, err := ExtractIdFromWebSocketHeader(s)
	if err != nil {
		return err
	}

	var flightProposalRequest inputs.InputCreateFlightProposal
	err = json.Unmarshal([]byte(msg), &flightProposalRequest)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error unmarshalling flight proposal request", err.Error())
		return err
	}

	err = h.flightService.MakeFlightPriceProposal(flightProposalRequest, userId)

	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error making flight proposal", err.Error())
		return err
	}

	h.socketIoServer.BroadcastToRoom("/flights", strconv.Itoa(flightProposalRequest.FlightId), "flightUpdated", "flight updated")
	s.Join(strconv.Itoa(flightProposalRequest.FlightId))

	go func() {
		//TODO: The time sleep is really dirty, we need to find a better way to do this
		time.Sleep(2 * time.Second)

		err := estimateAndBroadcastFlightTime(s, flightProposalRequest.FlightId, h.flightService, h.socketIoServer)
		if err != nil {
			log.Println("Error estimating flight time:", err)
		}
	}()

	return nil
}

func (h *FlightSocketHandler) FlightProposalChoice(s socketio.Conn, msg string) error {
	userId, err := ExtractIdFromWebSocketHeader(s)
	if err != nil {
		return err
	}

	var flightProposalChoice inputs.InputFlightProposalChoice
	err = json.Unmarshal([]byte(msg), &flightProposalChoice)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error unmarshalling flight proposal choice", err.Error())
		return err
	}

	err = h.flightService.FlightProposalChoice(flightProposalChoice, userId)

	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error making flight proposal choice", err.Error())
		return err
	}

	h.socketIoServer.BroadcastToRoom("/flights", strconv.Itoa(flightProposalChoice.FlightId), "flightUpdated", "flight updated")
	if flightProposalChoice.Choice == "accepted" {
		s.Join(strconv.Itoa(flightProposalChoice.FlightId))

		h.startPilotPositionUpdate(s, strconv.Itoa(flightProposalChoice.FlightId))
	}

	return nil
}

func (h *FlightSocketHandler) FlightTakeoff(s socketio.Conn, flightId string) error {
	pilotId, err := ExtractIdFromWebSocketHeader(s)
	if err != nil {
		return err
	}

	convertedFlightId, err := strconv.Atoi(flightId)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error extracting flight ID", err.Error())
		return err
	}

	err = h.flightService.FlightTakeoff(convertedFlightId, pilotId)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error taking off flight", err.Error())
		return err
	}

	h.socketIoServer.BroadcastToRoom("/flights", flightId, "flightUpdated", "flight updated")
	return nil
}

func (h *FlightSocketHandler) FlightLanding(s socketio.Conn, flightId string) error {
	pilotId, err := ExtractIdFromWebSocketHeader(s)
	if err != nil {
		return err
	}

	convertedFlightId, err := strconv.Atoi(flightId)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error extracting flight ID", err.Error())
		return err
	}

	err = h.flightService.FlightLanding(convertedFlightId, pilotId)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error landing flight", err.Error())
		return err
	}

	h.socketIoServer.BroadcastToRoom("/flights", flightId, "flightUpdated", "flight updated")
	h.socketIoServer.ClearRoom("/flights", flightId)

	return nil
}

func (h *FlightSocketHandler) CancelFlight(s socketio.Conn, flightId string) error {
	userId, err := ExtractIdFromWebSocketHeader(s)
	if err != nil {
		return err
	}

	convertedFlightId, err := strconv.Atoi(flightId)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error extracting flight ID", err.Error())
		return err
	}

	err = h.flightService.CancelFlight(convertedFlightId, userId)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error cancelling flight", err.Error())
		return err
	}

	h.socketIoServer.BroadcastToRoom("/flights", flightId, "flightUpdated", "flight updated")
	h.StopGoroutine(s.ID())

	h.socketIoServer.ClearRoom("/flights", flightId)

	return nil
}

func estimateAndBroadcastFlightTime(s socketio.Conn, flightId int, flightService services.FlightServiceInterface, socketIoServer *socketio.Server) error {
	flight, err := flightService.GetFlight(flightId)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error getting flight", err.Error())
		return err
	}

	//TODO: This is temporary, we need to get the pilot's real position
	pilotPosition := utils.Position{
		Latitude:  flight.Departure.Latitude,
		Longitude: flight.Departure.Longitude,
	}

	estimateFlightTimeInHour, err := flightService.EstimateFlightTimeInHour(flightId, pilotPosition)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error estimating flight time", err.Error())
		return err
	}

	socketIoServer.BroadcastToRoom("/flights", strconv.Itoa(flightId), "flightTimeUpdated", strconv.FormatFloat(estimateFlightTimeInHour, 'f', 2, 64))

	log.Println("Emitting flightTimeUpdated event")
	return nil
}

func (h *FlightSocketHandler) startPilotPositionUpdate(s socketio.Conn, flightId string) {
	if oldStopChan, ok := h.stopChans[s.ID()]; ok {
		log.Println("Stopping old goroutine")
		close(oldStopChan)
	}

	stopChan := make(chan struct{})
	h.stopChans[s.ID()] = stopChan

	convertedFlightId, err := strconv.Atoi(flightId)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error extracting flight ID", err.Error())
		return
	}

	flight, err := h.flightService.GetFlight(convertedFlightId)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error getting flight", err.Error())
		return
	}

	//TODO: This is temporary, we need to get the pilot's real position
	pilotPosition := responses.ResponsePilotPosition{
		Latitude:  flight.Departure.Latitude,
		Longitude: flight.Departure.Longitude,
	}

	pilotPositionBytes, err := json.Marshal(pilotPosition)
	if err != nil {
		log.Println("Error marshalling pilot position:", err)
		return
	}

	pilotPositionString := string(pilotPositionBytes)

	h.socketIoServer.BroadcastToRoom("/flights", flightId, "pilotPositionUpdate", pilotPositionString)
	go func() {
		ticker := time.NewTicker(30 * time.Second)
		defer ticker.Stop()

		for {
			select {
			case <-ticker.C:
				h.socketIoServer.BroadcastToRoom("/flights", flightId, "pilotPositionUpdate", pilotPositionString)
				log.Println("sent pilot position update")
			case <-stopChan:
				return
			}
		}
	}()

	log.Println("Go routine started")

}

func (h *FlightSocketHandler) StopGoroutine(chanId string) {
	if stopChan, ok := h.stopChans[chanId]; ok {
		close(stopChan)
		delete(h.stopChans, chanId)
		log.Println("Goroutine stopped")
	}
}

func ExtractIdFromWebSocketHeader(s socketio.Conn) (int, error) {
	tokenString := s.RemoteHeader().Get("Bearer")
	userId, err := token.ExtractTokenIDFromToken(tokenString)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error extracting user ID from token", err.Error())
		return 0, err
	}
	return userId, nil
}
