package repositories

import (
	"backend/models"
	"gorm.io/gorm"
)

type MessageRepositoryInterface interface {
	GetMessageByID(messageID int) (models.Message, error)
	GetAllMessages(limit int, offset int) ([]models.Message, error)
	GetAllMessagesByFlightID(flightID int, limit int, offset int) ([]models.Message, error)
	CreateMessage(message models.Message) (models.Message, error)
}

type MessageRepository struct {
	db *gorm.DB
}

func NewMessageRepository(db *gorm.DB) *MessageRepository {
	return &MessageRepository{db}
}

func (r *MessageRepository) GetAllMessages(limit int, offset int) ([]models.Message, error) {
	var messages []models.Message
	query := r.db.Preload("User").Offset(offset).Limit(limit)
	err := query.Find(&messages).Error

	if err != nil {
		return messages, err
	}

	return messages, nil
}

func (r *MessageRepository) GetAllMessagesByFlightID(flightID int, limit int, offset int) ([]models.Message, error) {
	var messages []models.Message
	query := r.db.Preload("User").Where("flight_id = ?", flightID).Offset(offset).Limit(limit)
	err := query.Find(&messages).Error

	if err != nil {
		return messages, err
	}

	return messages, nil
}

func (r *MessageRepository) GetMessageByID(messageID int) (models.Message, error) {
	var message models.Message
	err := r.db.Preload("User").Where("id = ?", messageID).First(&message).Error
	if err != nil {
		return message, err
	}

	return message, nil
}

func (r *MessageRepository) CreateMessage(message models.Message) (models.Message, error) {
	err := r.db.Create(&message).Error
	if err != nil {
		return message, err
	}

	err = r.db.Preload("User").Where("id = ?", message.ID).First(&message).Error
	if err != nil {
		return message, err
	}

	return message, nil
}
