package services

import (
	flightStatus "backend/data/flight-status"
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
	"fmt"
)

type ProposalServiceInterface interface {
	GetAllProposals(limit int, offset int) ([]responses.ResponseProposal, error)
	CreateProposal(input inputs.InputCreateProposal, userID int) (responses.ResponseProposal, error)
	GetProposal(proposalID int) (responses.ResponseProposal, error)
	UpdateProposal(proposalID int, input inputs.InputUpdateProposal) (responses.ResponseProposal, error)
	DeleteProposal(id int) error
	JoinProposal(proposalID int, userID int) error
	LeaveProposal(proposalID int, userID int) error
}

type ProposalService struct {
	repository       repositories.ProposalRepositoryInterface
	flightRepository repositories.FlightRepositoryInterface
}

func NewProposalService(r repositories.ProposalRepositoryInterface, rf repositories.FlightRepositoryInterface) *ProposalService {
	return &ProposalService{
		repository:       r,
		flightRepository: rf,
	}
}

func (s *ProposalService) GetAllProposals(limit int, offset int) ([]responses.ResponseProposal, error) {
	proposals, err := s.repository.GetAllProposals(limit, offset)
	if err != nil {
		return []responses.ResponseProposal{}, err
	}

	responseProposals := formatProposals(proposals)

	return responseProposals, nil
}

func (s *ProposalService) CreateProposal(input inputs.InputCreateProposal, userID int) (responses.ResponseProposal, error) {
	flight := models.Flight{
		Status:             flightStatus.PROPOSAL,
		DepartureName:      input.CreateFlight.Departure.Name,
		DepartureAddress:   input.CreateFlight.Departure.Address,
		DepartureLatitude:  input.CreateFlight.Departure.Latitude,
		DepartureLongitude: input.CreateFlight.Departure.Longitude,
		ArrivalName:        input.CreateFlight.Arrival.Name,
		ArrivalAddress:     input.CreateFlight.Arrival.Address,
		ArrivalLatitude:    input.CreateFlight.Arrival.Latitude,
		ArrivalLongitude:   input.CreateFlight.Arrival.Longitude,
		Price:              &input.Price,
		VehicleID:          &input.VehicleID,
		PilotID:            &userID,
	}

	flight, err := s.flightRepository.CreateFlight(flight)

	if err != nil {
		return responses.ResponseProposal{}, err
	}

	proposal := models.Proposal{
		DepartureTime:  input.DepartureTime,
		Description:    input.Description,
		AvailableSeats: input.AvailableSeats,
		Flight:         flight,
	}

	proposal, err = s.repository.CreateProposal(proposal)
	if err != nil {
		return responses.ResponseProposal{}, err
	}

	formattedProposal := formatProposal(proposal)

	return formattedProposal, nil
}

func (s *ProposalService) GetProposal(proposalID int) (responses.ResponseProposal, error) {
	proposal, err := s.repository.GetProposalByID(proposalID)
	if err != nil {
		return responses.ResponseProposal{}, err
	}

	formattedProposal := formatProposal(proposal)

	return formattedProposal, nil
}

func (s *ProposalService) UpdateProposal(proposalID int, input inputs.InputUpdateProposal) (responses.ResponseProposal, error) {
	proposal, err := s.repository.GetProposalByID(proposalID)
	if err != nil {
		return responses.ResponseProposal{}, err
	}

	err = s.repository.UpdateProposal(&proposal, input)
	if err != nil {
		return responses.ResponseProposal{}, err
	}

	formattedProposal := formatProposal(proposal)

	return formattedProposal, nil
}

func (s *ProposalService) DeleteProposal(id int) error {
	proposal, err := s.repository.GetProposalByID(id)
	if err != nil {
		return err
	}

	return s.repository.DeleteProposal(proposal)
}

func (s *ProposalService) JoinProposal(proposalID int, userID int) error {
	proposal, err := s.repository.GetProposalByID(proposalID)
	if err != nil {
		return err
	}

	var flight models.Flight
	flight, err = s.flightRepository.GetFlightByID(proposal.FlightID)

	//----Check if someone can join----
	if flight.PilotID != nil && *flight.PilotID == userID {
		return fmt.Errorf("pilot cannot join their own flight")
	}
	if len(flight.Users) >= proposal.AvailableSeats {
		return fmt.Errorf("no available seats")
	}
	//----------------------------------

	flight.Users = append(flight.Users, &models.User{ID: userID})
	if err != nil {
		return err
	}

	flight, err = s.flightRepository.UpdateFlight(flight)

	return nil
}

func (s *ProposalService) LeaveProposal(proposalID int, userID int) error {
	proposal, err := s.repository.GetProposalByID(proposalID)
	if err != nil {
		return err
	}

	var flight models.Flight
	flight, err = s.flightRepository.GetFlightByID(proposal.FlightID)
	for i, user := range flight.Users {
		if user.ID == userID {
			flight.Users = append(flight.Users[:i], flight.Users[i+1:]...)
		}
	}
	if err != nil {
		return err
	}

	//----Check if someone can leave----
	if flight.PilotID != nil && *flight.PilotID == userID {
		return fmt.Errorf("pilot cannot leave their own flight")
	}
	//----------------------------------

	flight, err = s.flightRepository.UpdateFlight(flight)

	return nil
}

func formatProposal(proposal models.Proposal) responses.ResponseProposal {
	var flight responses.ResponseFlight

	flight = responses.ResponseFlight{
		ID:        proposal.Flight.ID,
		Status:    proposal.Flight.Status,
		Price:     proposal.Flight.Price,
		VehicleID: proposal.Flight.VehicleID,
		PilotID:   proposal.Flight.PilotID,
		Departure: responses.ResponseAirport{
			Name:      proposal.Flight.DepartureName,
			Address:   proposal.Flight.DepartureAddress,
			Latitude:  proposal.Flight.DepartureLatitude,
			Longitude: proposal.Flight.DepartureLongitude,
		},
		Arrival: responses.ResponseAirport{
			Name:      proposal.Flight.ArrivalName,
			Address:   proposal.Flight.ArrivalAddress,
			Latitude:  proposal.Flight.ArrivalLatitude,
			Longitude: proposal.Flight.ArrivalLongitude,
		},
		CreatedAt: proposal.Flight.CreatedAt,
		UpdatedAt: proposal.Flight.UpdatedAt,
		Pilot: &responses.ListUser{
			ID:        proposal.Flight.Pilot.ID,
			FirstName: proposal.Flight.Pilot.FirstName,
			LastName:  proposal.Flight.Pilot.LastName,
			Email:     proposal.Flight.Pilot.Email,
			Role:      proposal.Flight.Pilot.Role,
			CreatedAt: proposal.Flight.Pilot.CreatedAt,
			UpdatedAt: proposal.Flight.Pilot.UpdatedAt,
		},
		Vehicle: &responses.Vehicle{
			ID:             proposal.Flight.Vehicle.ID,
			ModelName:      proposal.Flight.Vehicle.ModelName,
			Matriculation:  proposal.Flight.Vehicle.Matriculation,
			Seat:           proposal.Flight.Vehicle.Seat,
			Type:           proposal.Flight.Vehicle.Type,
			CruiseSpeed:    proposal.Flight.Vehicle.CruiseSpeed,
			CruiseAltitude: proposal.Flight.Vehicle.CruiseAltitude,
			IsVerified:     proposal.Flight.Vehicle.IsVerified,
			CreatedAt:      proposal.Flight.Vehicle.CreatedAt,
			UpdatedAt:      proposal.Flight.Vehicle.UpdatedAt,
		},
		Users: formatUsers(proposal.Flight.Users),
	}

	return responses.ResponseProposal{
		ID:             proposal.ID,
		DepartureTime:  proposal.DepartureTime,
		Description:    proposal.Description,
		AvailableSeats: proposal.AvailableSeats,
		Flight:         flight,
	}
}

func formatProposals(proposals []models.Proposal) []responses.ResponseProposal {
	var responseProposals []responses.ResponseProposal
	for _, proposal := range proposals {
		responseProposals = append(responseProposals, formatProposal(proposal))
	}
	return responseProposals
}
