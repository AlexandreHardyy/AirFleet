package repositories

import (
	"backend/models"
	"errors"
	"gorm.io/gorm"
)

type FlightRepositoryInterface interface {
	CreateFlight(flight models.Flight) (models.Flight, error)
	GetCurrentFlight(userID int) (models.Flight, error)
}

type FlightRepository struct {
	db *gorm.DB
}

func NewFlightRepository(db *gorm.DB) *FlightRepository {
	return &FlightRepository{db}
}

func (r *FlightRepository) GetCurrentFlight(userID int) (models.Flight, error) {
	var flight models.Flight
	err := r.db.Where("user_id = ? AND status != ?", userID, "finished").First(&flight).Error
	if err != nil {
		return flight, err
	}
	return flight, nil
}

func (r *FlightRepository) CreateFlight(flight models.Flight) (models.Flight, error) {
	currentFlight, err := r.GetCurrentFlight(flight.UserID)

	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return flight, errors.New("error: cannot retrieve current flight")
	}

	if currentFlight.ID != 0 {
		return flight, errors.New("cannot create new flight, you still have an active flight")
	}

	err = r.db.Create(&flight).Error
	if err != nil {
		return flight, err
	}
	return flight, nil
}
