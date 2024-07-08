package repositories

import (
	flightStatus "backend/data/flight-status"
	"backend/models"
	"gorm.io/gorm"
)

type FlightRepositoryInterface interface {
	GetAllFlights(limit int, offset int) ([]models.Flight, error)
	GetFlightByID(flightID int) (models.Flight, error)
	GetFlightsByUserID(userID int) ([]models.Flight, error)
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

func (r *FlightRepository) GetAllFlights(limit int, offset int) ([]models.Flight, error) {
	var flights []models.Flight
	query := r.db.Preload("Pilot").Preload("Users").Preload("Vehicle").Offset(offset).Limit(limit)
	err := query.Find(&flights).Error
	if err != nil {
		return flights, err
	}
	return flights, nil
}

func (r *FlightRepository) GetFlightByID(flightID int) (models.Flight, error) {
	var flight models.Flight
	err := r.db.Preload("Pilot").Preload("Users").Preload("Vehicle").Where("id = ?", flightID).First(&flight).Error
	if err != nil {
		return flight, err
	}
	return flight, nil
}

func (r *FlightRepository) GetFlightsByUserID(userID int) ([]models.Flight, error) {
	var flights []models.Flight
	err := r.db.Preload("Pilot").
		Preload("Users").
		Preload("Vehicle").
		Joins("JOIN flight_users ON flight_users.flight_id = flights.id").
		Where("flight_users.user_id = ?", userID).
		Find(&flights).Error
	if err != nil {
		return flights, err
	}
	return flights, nil
}

func (r *FlightRepository) GetFlightRequests() ([]models.Flight, error) {
	var flights []models.Flight
	err := r.db.Preload("Users").Where(models.Flight{Status: flightStatus.WAITING_PILOT}).Find(&flights).Error
	if err != nil {
		return flights, err
	}
	return flights, nil
}

func (r *FlightRepository) GetCurrentFlight(userID int) (models.Flight, error) {
	var flight models.Flight
	err := r.db.
		Preload("Pilot").
		Preload("Vehicle").
		Preload("Users").
		Joins("JOIN flight_users ON flight_users.flight_id = flights.id").
		Where("(flight_users.user_id = ? OR flights.pilot_id = ?) AND flights.status != ? AND flights.status != ?", userID, userID, flightStatus.FINISHED, flightStatus.CANCELLED).
		First(&flight).Error
	if err != nil {
		return flight, err
	}
	return flight, nil
}

func (r *FlightRepository) CreateFlight(flight models.Flight) (models.Flight, error) {
	err := r.db.Create(&flight).Error
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
