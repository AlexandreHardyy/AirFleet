package services

import (
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
)

type FlightServiceInterface interface {
	CreateFlight(input inputs.InputCreateFlight, userID int) (responses.ResponseFlight, error)
	GetCurrentFlight(userID int) (responses.ResponseFlight, error)
}

type FlightService struct {
	repository repositories.FlightRepositoryInterface
}

func NewFlightService(r repositories.FlightRepositoryInterface) *FlightService {
	return &FlightService{r}
}

func (s *FlightService) CreateFlight(input inputs.InputCreateFlight, userID int) (responses.ResponseFlight, error) {
	flight := models.Flight{
		//TODO: Status can be different based on the user role
		Status:             "waiting_pilot",
		DepartureName:      input.Departure.Name,
		DepartureAddress:   input.Departure.Address,
		DepartureLatitude:  input.Departure.Latitude,
		DepartureLongitude: input.Departure.Longitude,
		ArrivalName:        input.Arrival.Name,
		ArrivalAddress:     input.Arrival.Address,
		ArrivalLatitude:    input.Arrival.Latitude,
		ArrivalLongitude:   input.Arrival.Longitude,
		UserID:             userID,
	}

	flight, err := s.repository.CreateFlight(flight)
	if err != nil {
		return responses.ResponseFlight{}, err
	}

	formattedFlight := formatFlight(flight)

	return formattedFlight, nil
}

func (s *FlightService) GetCurrentFlight(userID int) (responses.ResponseFlight, error) {
	flight, err := s.repository.GetCurrentFlight(userID)
	if err != nil {
		return responses.ResponseFlight{}, err
	}

	formattedFlight := formatFlight(flight)

	return formattedFlight, nil
}

func formatFlight(flight models.Flight) responses.ResponseFlight {
	return responses.ResponseFlight{
		ID:     flight.ID,
		Status: flight.Status,
		Departure: responses.ResponseAirport{
			Name:      flight.DepartureName,
			Address:   flight.DepartureAddress,
			Latitude:  flight.DepartureLatitude,
			Longitude: flight.DepartureLongitude,
		},
		Arrival: responses.ResponseAirport{
			Name:      flight.ArrivalName,
			Address:   flight.ArrivalAddress,
			Latitude:  flight.ArrivalLatitude,
			Longitude: flight.ArrivalLongitude,
		},
		CreatedAt: flight.CreatedAt,
		UpdatedAt: flight.UpdatedAt,
	}
}
