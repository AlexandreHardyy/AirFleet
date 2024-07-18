package handlers

import (
	"backend/customErrors"
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/services"
	"backend/utils/token"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	socketio "github.com/googollee/go-socket.io"
	"gorm.io/gorm"
)

// REST

type MessageHandler struct {
	messageService services.MessageServiceInterface
}

func GetMessageHandler(db *gorm.DB) *MessageHandler {
	messageRepository := repositories.NewMessageRepository(db)
	messageService := services.NewMessageService(messageRepository)
	return newMessageHandler(messageService)
}

func newMessageHandler(messageService services.MessageServiceInterface) *MessageHandler {
	return &MessageHandler{messageService}
}

// GetAllByFlightID godoc
//
// @Summary Get all messages by flight ID
// @Schemes
// @Description Get all messages by flight ID
// @Tags messages
// @Accept			json
// @Produce		json
//
// @Param			flightId	path	int		true	"Flight ID"
// @Param			limit	query	int		false	"Limit"
// @Param			offset	query	int		false	"Offset"
//
// @Success		200				{object}	[]responses.ResponseMessage
// @Failure		400				{object}	Response
//
// @Router			/messages/flight/{flightId} [get]
//
// @Security	BearerAuth
func (h *MessageHandler) GetAllByFlightID(c *gin.Context) {
	flightID, _ := strconv.Atoi(c.Param("flightId"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "100"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	userID, err := token.ExtractTokenID(c)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract user ID",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	messages, err := h.messageService.GetAllMessagesByFlightID(flightID, userID, limit, offset)
	if err != nil {
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[GetAllMessagesByFlightID]: " + err.Error(),
		})
		var customErr *customErrors.CustomError
		if errors.As(err, &customErr) {
			c.JSON(customErr.StatusCode, gin.H{"error": customErr.Message})
			return
		}
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, messages)
}

// Websocket

type MessageSocketHandler struct {
	messageService services.MessageServiceInterface
	socketIoServer *socketio.Server
}

func GetMessageSocketHandler(db *gorm.DB, server *socketio.Server) *MessageSocketHandler {
	messageRepository := repositories.NewMessageRepository(db)
	messageService := services.NewMessageService(messageRepository)
	return NewMessageSocketHandler(messageService, server)
}

func NewMessageSocketHandler(messageService services.MessageServiceInterface, socketIoServer *socketio.Server) *MessageSocketHandler {
	return &MessageSocketHandler{messageService, socketIoServer}
}

func (h *MessageSocketHandler) CreateMessage(s socketio.Conn, msg string) error {
	userId, err := ExtractIdFromWebSocketHeader(s)
	if err != nil {
		return err
	}

	var inputCreateMessage inputs.InputCreateMessage
	err = json.Unmarshal([]byte(msg), &inputCreateMessage)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error unmarshalling createMessage input", err.Error())
		return err
	}

	message, err := h.messageService.CreateMessage(inputCreateMessage, userId)
	if err != nil {
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[CreateMessage]: " + err.Error(),
		})
		s.Emit("error", err.Error())
		log.Println("Error creating message", err.Error())
		return err
	}

	responseBytes, err := json.Marshal(message)
	if err != nil {
		s.Emit("error", err.Error())
		log.Println("Error marshalling message", err.Error())
		return err
	}

	response := string(responseBytes)

	log.Println(h.socketIoServer.Rooms("/flights"))
	log.Println(strconv.Itoa(inputCreateMessage.FlightID))
	log.Println(s.Rooms())

	h.socketIoServer.BroadcastToRoom("/flights", strconv.Itoa(inputCreateMessage.FlightID), "newMessageFront", response)

	return nil
}
