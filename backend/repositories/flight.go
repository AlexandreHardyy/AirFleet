package repositories

import (
	"backend/models"
	"gorm.io/gorm"
)

type FlightRepositoryInterface interface {
	CreateFlight(flight models.Flight) (models.Flight, error)
}

type FlightRepository struct {
	db *gorm.DB
}

func NewFlightRepository(db *gorm.DB) *FlightRepository {
	return &FlightRepository{db}
}

func (r *FlightRepository) CreateFlight(flight models.Flight) (models.Flight, error) {
	err := r.db.Create(&flight).Error
	if err != nil {
		return flight, err
	}
	return flight, nil
}
