package utils

import (
	"backend/models"
	"backend/services"
	"backend/utils"
	"github.com/stretchr/testify/mock"
	"math"
	"testing"
)

type FlightRepositoryInterface struct {
	mock.Mock
}

func (m *FlightRepositoryInterface) GetFlightByID(id int) (models.Flight, error) {
	args := m.Called(id)
	return args.Get(0).(models.Flight), args.Error(1)
}

func (m *FlightRepositoryInterface) CreateFlight(flight models.Flight) (models.Flight, error) {
	args := m.Called(flight)
	return args.Get(0).(models.Flight), args.Error(1)
}

func (m *FlightRepositoryInterface) GetCurrentFlight(userID int) (models.Flight, error) {
	args := m.Called(userID)
	return args.Get(0).(models.Flight), args.Error(1)
}

func (m *FlightRepositoryInterface) GetFlightRequests() ([]models.Flight, error) {
	args := m.Called()
	return args.Get(0).([]models.Flight), args.Error(1)
}

func (m *FlightRepositoryInterface) UpdateFlight(flight models.Flight) (models.Flight, error) {
	args := m.Called(flight)
	return args.Get(0).(models.Flight), args.Error(1)
}

func (m *FlightRepositoryInterface) GetAllFlights(limit int, offset int) ([]models.Flight, error) {
	args := m.Called(limit, offset)
	return args.Get(0).([]models.Flight), args.Error(1)
}

func (m *FlightRepositoryInterface) GetFlightsByUserID(userID int) ([]models.Flight, error) {
	args := m.Called(userID)
	return args.Get(0).([]models.Flight), args.Error(1)
}

func TestEstimateFlightTimeInHour(t *testing.T) {
	// Mock the repository to return a specific flight
	mockRepo := new(FlightRepositoryInterface)
	mockRepo.On("GetFlightByID", 1).Return(models.Flight{
		ArrivalLatitude:  40.712776,
		ArrivalLongitude: -74.005974,
		Vehicle: models.Vehicle{
			CruiseSpeed: 300,
		},
	}, nil)

	service := services.NewFlightService(mockRepo)

	// Define a pilot position
	pilotPosition := utils.Position{
		Latitude:  34.052235,
		Longitude: -118.243683,
	}

	// Call the function with the mock repository and pilot position
	estimatedTime, err := service.EstimateFlightTimeInHour(1, pilotPosition)

	// Assert that there was no error and the estimated time is as expected
	if err != nil {
		t.Errorf("Expected no error, but got %v", err)
	}

	// The expected time is based on the distance between the two points divided by the cruise speed
	// Adjust this value based on your actual calculation
	expectedTime := 7.08
	if estimatedTime != expectedTime {
		t.Errorf("Expected time %v, but got %v", expectedTime, estimatedTime)
	}
}

func TestComputeDistanceInKm(t *testing.T) {
	p1 := utils.Position{
		Latitude:  40.712776,
		Longitude: -74.005974,
	}
	p2 := utils.Position{
		Latitude:  34.052235,
		Longitude: -118.243683,
	}

	distance := utils.ComputeDistanceInKm(p1, p2)

	// The expected distance is based on the known distance between the two points
	// Adjust this value based on your actual calculation
	expectedDistance := 3935.75 // in kilometers

	// Use a small tolerance when comparing floating point numbers
	tolerance := 0.20

	if math.Abs(distance-expectedDistance) > tolerance {
		t.Errorf("Expected distance %v, but got %v", expectedDistance, distance)
	}
}

func TestComputeDistanceInNauticalMiles(t *testing.T) {
	p1 := utils.Position{
		Latitude:  40.712776,
		Longitude: -74.005974,
	}
	p2 := utils.Position{
		Latitude:  34.052235,
		Longitude: -118.243683,
	}

	distance := utils.ComputeDistanceInNauticalMiles(p1, p2)

	// The expected distance is based on the known distance between the two points
	// Adjust this value based on your actual calculation
	expectedDistance := 2125.00 // in nautical miles

	// Use a small tolerance when comparing floating point numbers
	tolerance := 0.20

	if math.Abs(distance-expectedDistance) > tolerance {
		t.Errorf("Expected distance %v, but got %v", expectedDistance, distance)
	}
}
