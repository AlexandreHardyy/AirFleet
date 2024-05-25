package services

import (
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
	"errors"
	"gorm.io/gorm"
	"log"
)

type FlightServiceInterface interface {
	//REST
	CreateFlight(input inputs.InputCreateFlight, userID int) (responses.ResponseFlight, error)
	GetCurrentFlight(userID int) (responses.ResponseFlight, error)
	//WEBSOCKET
	JoinFlightSession(flightID int, userID int) error
	MakeFlightPriceProposal(input inputs.InputCreateFlightProposal, userID int) error
	FlightProposalChoice(input inputs.InputFlightProposalChoice, userID int) error
}

type FlightService struct {
	repository repositories.FlightRepositoryInterface
}

func NewFlightService(r repositories.FlightRepositoryInterface) *FlightService {
	return &FlightService{r}
}

//REST

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
	var price float64
	var pilotID int

	if flight.Price != nil {
		price = *flight.Price
	}

	if flight.PilotID != nil {
		pilotID = *flight.PilotID
	}

	return responses.ResponseFlight{
		ID:      flight.ID,
		Status:  flight.Status,
		Price:   price,
		UserID:  flight.UserID,
		PilotID: pilotID,
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

//WEBSOCKET

func (s *FlightService) JoinFlightSession(flightID int, userID int) error {
	flight, err := s.repository.GetFlightByID(flightID)
	if err != nil {
		return err
	}

	if flight.Status == "waiting_pilot" && flight.UserID == userID {
		return nil
	}

	return nil
}

func (s *FlightService) MakeFlightPriceProposal(input inputs.InputCreateFlightProposal, userID int) error {
	flight, err := s.repository.GetFlightByID(input.FlightId)
	if err != nil {
		return err
	}

	currentFlight, err := s.repository.GetCurrentFlight(userID)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return err
	}

	if flight.Status != "waiting_pilot" || currentFlight.ID != 0 {
		return errors.New("flight is not available for price proposal")
	}

	flight.Status = "waiting_proposal_approval"
	flight.Price = &input.Price
	flight.PilotID = &userID
	_, err = s.repository.UpdateFlight(flight)
	if err != nil {
		return err
	}

	return nil
}

func (s *FlightService) FlightProposalChoice(input inputs.InputFlightProposalChoice, userID int) error {
	flight, err := s.repository.GetFlightByID(input.FlightId)
	if err != nil {
		return err
	}

	if flight.Status != "waiting_proposal_approval" || flight.UserID != userID {
		return errors.New("flight is not available for proposal choice")
	}

	if input.Choice == "accepted" {
		flight.Status = "waiting_takeoff"
		log.Println(flight)
	} else if input.Choice == "rejected" {
		flight.Status = "waiting_pilot"
		flight.PilotID = nil
		flight.Price = nil
	}

	log.Println(flight)

	_, err = s.repository.UpdateFlight(flight)

	if err != nil {
		return err
	}

	return nil
}
