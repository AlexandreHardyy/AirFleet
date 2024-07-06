package services

import (
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
	"time"
)

type ProposalServiceInterface interface {
	GetAllProposals(limit int, offset int) ([]responses.ResponseProposal, error)
	CreateProposal(input inputs.InputCreateProposal, userID int) (responses.ResponseProposal, error)
	GetProposal(proposalID int) (responses.ResponseProposal, error)
	DeleteProposal(id int) error
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
		DepartureTime:  time.Time{},
		Description:    input.Description,
		AvailableSeats: input.AvailableSeats,
		FlightID:       flight.ID,
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

func (s *ProposalService) DeleteProposal(id int) error {
	proposal, err := s.repository.GetProposalByID(id)
	if err != nil {
		return err
	}

	return s.repository.DeleteProposal(proposal)
}

func formatProposal(proposal models.Proposal) responses.ResponseProposal {
	return responses.ResponseProposal{
		ID:            proposal.ID,
		DepartureTime: proposal.DepartureTime,
		Flight:        responses.ResponseFlight{ID: proposal.Flight.ID}, // Adjust this line based on your Flight model
	}
}

func formatProposals(proposals []models.Proposal) []responses.ResponseProposal {
	var responseProposals []responses.ResponseProposal
	for _, proposal := range proposals {
		responseProposals = append(responseProposals, formatProposal(proposal))
	}
	return responseProposals
}
