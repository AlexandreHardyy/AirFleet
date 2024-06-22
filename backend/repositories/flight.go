package repositories

import (
	flightStatus "backend/data/flight-status"
	"backend/models"
	"errors"

	"gorm.io/gorm"
)

type FlightRepositoryInterface interface {
	GetFlightByID(flightID int) (models.Flight, error)
	CreateFlight(flight models.Flight) (models.Flight, error)
	GetCurrentFlight(userID int) (models.Flight, error)
	GetFlightRequests() ([]models.Flight, error)
	UpdateFlight(flight models.Flight) (models.Flight, error)
}

type FlightRepository struct {
	db *gorm.DB
}

func NewFlightRepository(db *gorm.DB) *FlightRepository {
	return &FlightRepository{db}
}

func (r *FlightRepository) GetFlightByID(flightID int) (models.Flight, error) {
	var flight models.Flight
	err := r.db.Preload("Pilot").Preload("Vehicle").Where("id = ?", flightID).First(&flight).Error
	if err != nil {
		return flight, err
	}
	return flight, nil
}

func (r *FlightRepository) GetFlightRequests() ([]models.Flight, error) {
	var flights []models.Flight
	err := r.db.Preload("User").Where(models.Flight{Status: flightStatus.WAITING_PILOT}).Find(&flights).Error
	if err != nil {
		return flights, err
	}
	return flights, nil
}

func (r *FlightRepository) GetCurrentFlight(userID int) (models.Flight, error) {
	var flight models.Flight
	err := r.db.Preload("Pilot").Preload("Vehicle").Where("(user_id = ? OR pilot_id = ?) AND status != ? AND status != ?", userID, userID, flightStatus.FINISHED, flightStatus.CANCELLED).First(&flight).Error
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

func (r *FlightRepository) UpdateFlight(flight models.Flight) (models.Flight, error) {
	err := r.db.Save(&flight).Error
	if err != nil {
		return flight, err
	}
	return flight, nil
}
