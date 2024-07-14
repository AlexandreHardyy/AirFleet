package repositories

import (
	"backend/database"
	"backend/models"

	"gorm.io/gorm"
)

type IPaymentRepository interface {
	Create(monitoringLog models.Payment) (models.Payment, error)
	GetById(userId int, flightId int) (models.Payment, error)
}

type PaymentRepository struct {
	db *gorm.DB
}

func NewPaymentRepository(db *gorm.DB) *PaymentRepository {
	return &PaymentRepository{db}
}

func (r *PaymentRepository) Create(payment models.Payment) (models.Payment, error) {
	err := r.db.Create(&payment).Error
	if err != nil {
		return payment, err
	}
	return payment, nil
}

func (r *PaymentRepository) GetById(userId int, flightId int) (models.Payment, error) {
	var payment models.Payment
	err := r.db.Where(models.Payment{UserID: userId, FlightID: flightId}).First(&payment).Error
	if err != nil {
		return payment, err
	}
	return payment, nil
}

func CreatePayment(payment models.Payment) (models.Payment, error) {
	repository := NewPaymentRepository(database.DB)

	return repository.Create(payment)
}
