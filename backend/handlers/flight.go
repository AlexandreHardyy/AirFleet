package handlers

import (
	"backend/inputs"
	"backend/repositories"
	"backend/services"
	"backend/utils/token"
	"encoding/json"
	"github.com/gin-gonic/gin"
	socketio "github.com/googollee/go-socket.io"
	"gorm.io/gorm"
	"log"
	"net/http"
	"strconv"
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
	}
}

func (h *FlightSocketHandler) CreateFlightSession(s socketio.Conn, flightId string) {
	log.Println("Flight session created")
	s.Join(flightId)
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
	s.Join(strconv.Itoa(flightProposalChoice.FlightId))

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

	h.socketIoServer.ClearRoom("/flights", flightId)

	return nil
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
