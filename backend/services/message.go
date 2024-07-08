package services

import (
	"backend/database"
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
	"backend/utils"
	"errors"
)

type MessageServiceInterface interface {
	GetAllMessages(limit int, offset int) ([]models.Message, error)
	GetAllMessagesByFlightID(flightID int, userID int, limit int, offset int) ([]models.Message, error)
	CreateMessage(message inputs.InputCreateMessage, userID int) (responses.ResponseMessage, error)
}

type MessageService struct {
	repository repositories.MessageRepositoryInterface
}

func NewMessageService(repository repositories.MessageRepositoryInterface) *MessageService {
	return &MessageService{repository}
}

func (s *MessageService) GetAllMessages(limit int, offset int) ([]models.Message, error) {
	messages, err := s.repository.GetAllMessages(limit, offset)
	if err != nil {
		return messages, err
	}

	return messages, nil
}

func (s *MessageService) GetAllMessagesByFlightID(flightID int, userID int, limit int, offset int) ([]models.Message, error) {
	flightRepository := repositories.NewFlightRepository(database.DB)

	flight, err := flightRepository.GetFlightByID(flightID)
	if err != nil {
		return nil, err
	}

	if utils.NotContainsUser(flight.Users, userID) && (flight.PilotID != nil && *flight.PilotID != userID) {
		return nil, errors.New("you are not authorized to view this flight's messages")
	}

	messages, err := s.repository.GetAllMessagesByFlightID(flightID, limit, offset)
	if err != nil {
		return messages, err
	}

	return messages, nil
}

func (s *MessageService) CreateMessage(message inputs.InputCreateMessage, userID int) (responses.ResponseMessage, error) {
	flightRepository := repositories.NewFlightRepository(database.DB)

	flight, err := flightRepository.GetFlightByID(message.FlightID)
	if err != nil {
		return responses.ResponseMessage{}, err
	}

	if utils.NotContainsUser(flight.Users, userID) && (flight.PilotID != nil && *flight.PilotID != userID) {
		return responses.ResponseMessage{}, errors.New("you are not authorized to send messages to this flight")
	}

	newMessage := models.Message{
		Content:  message.Content,
		UserID:   userID,
		FlightID: message.FlightID,
	}

	createdMessage, err := s.repository.CreateMessage(newMessage)
	if err != nil {
		return responses.ResponseMessage{}, err
	}

	formattedMessage := responses.ResponseMessage{
		ID:        createdMessage.ID,
		Content:   createdMessage.Content,
		UserID:    createdMessage.UserID,
		FlightID:  createdMessage.FlightID,
		CreatedAt: createdMessage.CreatedAt.Format("2006-01-02 15:04:05"),
		User: responses.ListUser{
			ID:         createdMessage.User.ID,
			FirstName:  createdMessage.User.FirstName,
			LastName:   createdMessage.User.LastName,
			Email:      createdMessage.User.Email,
			Role:       createdMessage.User.Role,
			IsVerified: createdMessage.User.IsVerified,
			CreatedAt:  createdMessage.User.CreatedAt,
			UpdatedAt:  createdMessage.User.UpdatedAt,
		},
	}

	return formattedMessage, nil
}
