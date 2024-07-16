package handlers

import (
	flightStatus "backend/data/flight-status"
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
	"backend/services"
	"backend/utils"
	"backend/utils/token"
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	socketio "github.com/googollee/go-socket.io"
	"gorm.io/gorm"
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

// GetAll godoc
//
// @Summary	Get all flights
// @Schemes
// @Description	get all flights
// @Tags			flight
// @Accept			json
// @Produce		json
//
// @Param			limit	query	int		false	"Limit"
// @Param			offset	query	int		false	"Offset"
//
// @Success		200				{object}	[]responses.ResponseFlight
// @Failure		400				{object}	Response
//
// @Router			/flights [get]
//
// @Security	BearerAuth
func (h *FlightHandler) GetAll(c *gin.Context) {
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	flights, err := h.flightService.GetAllFlights(limit, offset)
	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		_, err := repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[GetAllFlights]: " + err.Error(),
		})
		if err != nil {
			return
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	if len(flights) == 0 {
		c.JSON(http.StatusOK, []responses.ResponseFlight{})
		return
	}

	c.JSON(http.StatusOK, flights)
}

// GetFlight godoc
//
// @Summary	Get flight
// @Schemes
// @Description	get flight
// @Tags			flight
// @Accept			json
// @Produce		json
//
// @Param			id	path	int		true	"Flight ID"
//
// @Success		200				{object}	responses.ResponseFlight
// @Failure		400				{object}	Response
//
// @Router			/flights/{id} [get]
//
// @Security	BearerAuth
func (h *FlightHandler) GetFlight(c *gin.Context) {
	flightId, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, Response{
			Message: "Invalid flight ID",
		})
		return
	}

	flight, err := h.flightService.GetFlight(flightId)
	if err != nil {
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[GetFlight]: " + err.Error(),
		})
		c.JSON(http.StatusBadRequest, Response{
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, flight)
}

// FlightHistory godoc
//
// @Summary	Get flight history
// @Schemes
// @Description	get flight history
// @Tags			flight
// @Accept			json
// @Produce		json
//
// @Success		200				{object}	[]responses.ResponseFlight
// @Failure		400				{object}	Response
//
// @Router			/flights/history [get]
//
// @Security	BearerAuth
func (h *FlightHandler) FlightHistory(c *gin.Context) {
	userId, err := token.ExtractTokenID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, Response{
			Message: "Error: cannot extract user ID from token",
		})
		return
	}

	flights, err := h.flightService.GetFlightsByUserID(userId)
	if err != nil {
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[GetFlightsByUserID]: " + err.Error(),
		})
		c.JSON(http.StatusBadRequest, Response{
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, flights)
}

// GetFlightRequestsNearBy godoc
//
// @Summary	Get flight requests near by
// @Schemes
// @Description	get flight requests near by
// @Tags			flight
// @Accept			json
// @Produce		json
//
// @Param			latitude	query	float64	true	"Latitude"
// @Param			longitude	query	float64	true	"Longitude"
// @Param			range	query	float64	true	"Range"
//
// @Success		200				{object}	[]responses.ResponseFlight
// @Failure		400				{object}	Response
//
// @Router			/flights/nearby [get]
//
// @Security	BearerAuth
func (h *FlightHandler) GetFlightRequestsNearBy(c *gin.Context) {
	var queryParams inputs.NearByParams
	if err := c.ShouldBindQuery(&queryParams); err != nil {
		c.JSON(400, &Response{
			Message: err.Error(),
		})
		return
	}

	flights, err := h.flightService.GetFlightRequestNearBy(utils.Position{
		Latitude: queryParams.Latitude, Longitude: queryParams.Longitude,
	}, queryParams.Range)
	if err != nil {
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[GetFlightRequestNearBy]: " + err.Error(),
		})
		c.JSON(http.StatusInternalServerError, Response{
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, flights)
}

// Create CreateFlight godoc
//
// @Summary	Create flight
// @Schemes
// @Description	create a new flight
// @Tags			flight
// @Accept			json
// @Produce		json
//
// @Param			flightInput	body		inputs.CreateFlight	true	"Message body"
// @Success		201				{object}	responses.ResponseFlight
// @Failure		400				{object}	Response
//
// @Router			/flights [post]
//
// @Security	BearerAuth
func (h *FlightHandler) Create(c *gin.Context) {
	var input inputs.CreateFlight
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[CreateFlight]: " + err.Error(),
		})
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[GetCurrentFlight]: " + err.Error(),
		})
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[GetFlight]: " + err.Error(),
		})
		s.Emit("error", err.Error())
		log.Println("Error getting flight", err.Error())
		return
	}

	s.Join(flightId)

	if flight.Status == flightStatus.WAITING_PROPOSAL_APPROVAL {
		err = estimateAndBroadcastFlightTime(s, convertedFlightId, h.flightService, h.socketIoServer)
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[MakeFlightPriceProposal]: " + err.Error(),
		})
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
			repositories.CreateMonitoringLog(models.MonitoringLog{
				Type:    "error",
				Content: "[estimateAndBroadcastFlightTime]: " + err.Error(),
			})
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[FlightProposalChoice]: " + err.Error(),
		})
		s.Emit("error", err.Error())
		log.Println("Error making flight proposal choice", err.Error())
		return err
	}

	h.socketIoServer.BroadcastToRoom("/flights", strconv.Itoa(flightProposalChoice.FlightId), "flightUpdated", "flight updated")
	if flightProposalChoice.Choice == "rejected" {
		h.socketIoServer.ClearRoom("/flights", strconv.Itoa(flightProposalChoice.FlightId))
		s.Join(strconv.Itoa(flightProposalChoice.FlightId))
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[FlightTakeoff]: " + err.Error(),
		})
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[FlightLanding]: " + err.Error(),
		})
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[CancelFlight]: " + err.Error(),
		})
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[EstimateFlightTimeInHour]: " + err.Error(),
		})
		s.Emit("error", err.Error())
		log.Println("Error estimating flight time", err.Error())
		return err
	}

	socketIoServer.BroadcastToRoom("/flights", strconv.Itoa(flightId), "flightTimeUpdated", strconv.FormatFloat(estimateFlightTimeInHour, 'f', 2, 64))

	log.Println("Emitting flightTimeUpdated event")
	return nil
}

func (h *FlightSocketHandler) PilotPositionUpdate(s socketio.Conn, msg string) error {
	userId, err := ExtractIdFromWebSocketHeader(s)
	if err != nil {
		return err
	}

	var pilotPositionUpdate inputs.InputPilotPositionUpdate
	err = json.Unmarshal([]byte(msg), &pilotPositionUpdate)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error unmarshalling pilot position update", err.Error())
		return err
	}

	response, err := h.flightService.PilotPositionUpdate(pilotPositionUpdate, userId)
	if err != nil {
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[PilotPositionUpdate]: " + err.Error(),
		})
		s.Emit("error", err.Error())
		log.Println("Error updating pilot position", err.Error())
		return err
	}

	responseBytes, err := json.Marshal(response)
	if err != nil {
		log.Println("Error marshalling pilot position:", err)
		return err
	}

	responseString := string(responseBytes)

	h.socketIoServer.BroadcastToRoom("/flights", strconv.Itoa(pilotPositionUpdate.FlightId), "pilotPositionUpdated", responseString)

	return nil
}

// DEPRECATED
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[GetFlight]: " + err.Error(),
		})
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
}

func (h *FlightSocketHandler) StopGoroutine(chanId string) {
	if stopChan, ok := h.stopChans[chanId]; ok {
		close(stopChan)
		delete(h.stopChans, chanId)
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

func (h *FlightSocketHandler) StartAndCompleteFlight(s socketio.Conn, msg string) error {
	log.Println("Starting flight simulation")

	var simulationRequest inputs.InputSimulateFlight
	err := json.Unmarshal([]byte(msg), &simulationRequest)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error unmarshalling flight simulation request", err.Error())
		return err
	}

	flight, err := h.flightService.GetFlight(simulationRequest.FlightId)
	if err != nil {
		s.Emit("error", err.Error())
		return err
	}

	if flight.Status != flightStatus.WAITING_TAKEOFF {
		s.Emit("error", "Flight is not ready to take off")
		log.Println("Flight is not ready to take off")
		return nil
	}

	err = h.flightService.FlightTakeoff(simulationRequest.FlightId, simulationRequest.PilotId)
	if err != nil {
		s.Emit("error", err.Error())
		return err
	}
	log.Println("Flight has taken off")

	go func() {
		ticker := time.NewTicker(5 * time.Second)
		defer ticker.Stop()

		latDiff := flight.Arrival.Latitude - flight.Departure.Latitude
		longDiff := flight.Arrival.Longitude - flight.Departure.Longitude

		totalDistance := utils.CalculateDistance(flight.Departure.Latitude, flight.Departure.Longitude, flight.Arrival.Latitude, flight.Arrival.Longitude)

		cruiseSpeedKmH := flight.Vehicle.CruiseSpeed * 1.852 // Convert knots to km/h
		intervalSeconds := 5.0
		steps := int(totalDistance / (cruiseSpeedKmH * (intervalSeconds / 3600)))

		latIncrement := latDiff / float64(steps)
		longIncrement := longDiff / float64(steps)

		currentPosition := flight.Departure

		estimatedTime := totalDistance / cruiseSpeedKmH
		estimatedTimeInHours := int(estimatedTime)
		estimatedTimeInMinutes := int((estimatedTime - float64(estimatedTimeInHours)) * 60)
		log.Println("Estimated flight time:", estimatedTimeInHours, "hours", estimatedTimeInMinutes, "minutes")

		for i := 0; i < steps; i++ {
			select {
			case <-ticker.C:
				currentPosition.Latitude += latIncrement
				currentPosition.Longitude += longIncrement

				newPosition := inputs.InputPilotPositionUpdate{
					FlightId:  simulationRequest.FlightId,
					Latitude:  currentPosition.Latitude,
					Longitude: currentPosition.Longitude,
				}

				response, err := h.flightService.PilotPositionUpdate(newPosition, simulationRequest.PilotId)
				if err != nil {
					s.Emit("error", err.Error())
					return
				}

				responseBytes, err := json.Marshal(response)
				if err != nil {
					log.Println("Error marshalling pilot position:", err)
					return
				}

				responseString := string(responseBytes)

				h.socketIoServer.BroadcastToRoom("/flights", strconv.Itoa(simulationRequest.FlightId), "pilotPositionUpdated", responseString)
				log.Println("Pilot position updated")

				if currentPosition.Latitude >= flight.Arrival.Latitude && currentPosition.Longitude >= flight.Arrival.Longitude {
					break
				}
			}
		}

		err = h.flightService.FlightLanding(simulationRequest.FlightId, simulationRequest.PilotId)
		if err != nil {
			s.Emit("error", err.Error())
			return
		}
		log.Println("Flight has landed")

		s.Leave(strconv.Itoa(simulationRequest.FlightId))
	}()

	return nil
}
