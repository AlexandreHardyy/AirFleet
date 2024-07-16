package services

import (
	flightStatus "backend/data/flight-status"
	"backend/database"
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
	"backend/utils"
	"errors"
	"math"

	"gorm.io/gorm"
)

type FlightServiceInterface interface {
	//REST
	GetAllFlights(limit int, offset int) ([]responses.ResponseFlight, error)
	CreateFlight(input inputs.CreateFlight, userID int) (responses.ResponseFlight, error)
	GetFlight(flightID int) (responses.ResponseFlight, error)
	GetFlightsByUserID(userID int) ([]responses.ResponseFlight, error)
	GetCurrentFlight(userID int) (responses.ResponseFlight, error)
	GetFlightRequestNearBy(position utils.Position, rangeKm float64) ([]responses.ResponseFlight, error)
	//WEBSOCKET
	JoinFlightSession(flightID int, userID int) error
	MakeFlightPriceProposal(input inputs.InputCreateFlightProposal, userID int) error
	FlightProposalChoice(input inputs.InputFlightProposalChoice, userID int) error
	FlightTakeoff(flightID int, pilotId int) error
	PilotPositionUpdate(input inputs.InputPilotPositionUpdate, pilotId int) (responses.ResponsePilotPositionUpdate, error)
	FlightLanding(flightID int, pilotId int) error
	CancelFlight(flightID int, userId int) error
	EstimateFlightTimeInHour(flightID int, pilotPosition utils.Position) (float64, error)
}

type FlightService struct {
	repository repositories.FlightRepositoryInterface
}

func NewFlightService(r repositories.FlightRepositoryInterface) *FlightService {
	return &FlightService{r}
}

//REST

func (s *FlightService) GetAllFlights(limit int, offset int) ([]responses.ResponseFlight, error) {
	flights, err := s.repository.GetAllFlights(limit, offset)
	if err != nil {
		return []responses.ResponseFlight{}, err
	}

	responseFlights := formatFlights(flights)

	return responseFlights, nil
}

func (s *FlightService) CreateFlight(input inputs.CreateFlight, userID int) (responses.ResponseFlight, error) {
	flight := models.Flight{
		//TODO: Status can be different based on the user role
		Status:             flightStatus.WAITING_PILOT,
		DepartureName:      input.Departure.Name,
		DepartureAddress:   input.Departure.Address,
		DepartureLatitude:  input.Departure.Latitude,
		DepartureLongitude: input.Departure.Longitude,
		ArrivalName:        input.Arrival.Name,
		ArrivalAddress:     input.Arrival.Address,
		ArrivalLatitude:    input.Arrival.Latitude,
		ArrivalLongitude:   input.Arrival.Longitude,
		Users:              []*models.User{{ID: userID}},
	}

	currentFlight, err := s.repository.GetCurrentFlight(userID)

	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return formatFlight(flight), errors.New("error: cannot retrieve current flight")
	}

	if currentFlight.ID != 0 {
		return formatFlight(flight), errors.New("cannot create new flight, you still have an active flight")
	}

	flight, err = s.repository.CreateFlight(flight)
	if err != nil {
		return responses.ResponseFlight{}, err
	}

	formattedFlight := formatFlight(flight)

	return formattedFlight, nil
}

func (s *FlightService) GetFlight(flightID int) (responses.ResponseFlight, error) {
	flight, err := s.repository.GetFlightByID(flightID)
	if err != nil {
		return responses.ResponseFlight{}, err
	}

	formattedFlight := formatFlight(flight)

	return formattedFlight, nil
}

func (s *FlightService) GetFlightsByUserID(userID int) ([]responses.ResponseFlight, error) {
	flights, err := s.repository.GetFlightsByUserID(userID)
	if err != nil {
		return []responses.ResponseFlight{}, err
	}

	responseFlights := formatFlights(flights)

	return responseFlights, nil
}

func (s *FlightService) GetCurrentFlight(userID int) (responses.ResponseFlight, error) {
	flight, err := s.repository.GetCurrentFlight(userID)
	if err != nil {
		return responses.ResponseFlight{}, err
	}

	formattedFlight := formatFlight(flight)

	return formattedFlight, nil
}

func (s *FlightService) GetFlightRequestNearBy(position utils.Position, kmRange float64) ([]responses.ResponseFlight, error) {
	flights, err := s.repository.GetFlightRequests()

	var formattedFlights []responses.ResponseFlight
	for _, flight := range flights {
		flightPosition := utils.Position{
			Latitude:  flight.DepartureLatitude,
			Longitude: flight.DepartureLongitude,
		}

		if utils.ComputeDistanceInKm(flightPosition, position) <= kmRange {
			formattedFlights = append(formattedFlights, formatFlight(flight))
		}
	}
	return formattedFlights, err
}

func formatFlight(flight models.Flight) responses.ResponseFlight {
	var pilot *responses.ListUser
	var vehicle *responses.ResponseVehicle

	if flight.PilotID != nil {
		pilot = &responses.ListUser{
			ID:         flight.Pilot.ID,
			FirstName:  flight.Pilot.FirstName,
			LastName:   flight.Pilot.LastName,
			Email:      flight.Pilot.Email,
			Role:       flight.Pilot.Role,
			IsVerified: flight.Pilot.IsVerified,
			CreatedAt:  flight.Pilot.CreatedAt,
			UpdatedAt:  flight.Pilot.UpdatedAt,
		}
	}

	if flight.VehicleID != nil {
		vehicle = &responses.ResponseVehicle{
			ID:             flight.Vehicle.ID,
			ModelName:      flight.Vehicle.ModelName,
			Matriculation:  flight.Vehicle.Matriculation,
			Seat:           flight.Vehicle.Seat,
			Type:           flight.Vehicle.Type,
			CruiseSpeed:    flight.Vehicle.CruiseSpeed,
			CruiseAltitude: flight.Vehicle.CruiseAltitude,
			CreatedAt:      flight.Vehicle.CreatedAt,
			UpdatedAt:      flight.Vehicle.UpdatedAt,
		}
	}

	return responses.ResponseFlight{
		ID:        flight.ID,
		Status:    flight.Status,
		Price:     flight.Price,
		Users:     formatUsers(flight.Users),
		PilotID:   flight.PilotID,
		VehicleID: flight.VehicleID,
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
		Pilot:     pilot,
		Vehicle:   vehicle,
	}
}

func formatFlights(flights []models.Flight) []responses.ResponseFlight {
	var responseFlights []responses.ResponseFlight
	for _, flight := range flights {
		responseFlights = append(responseFlights, formatFlight(flight))
	}
	return responseFlights
}

//WEBSOCKET

func (s *FlightService) JoinFlightSession(flightID int, userID int) error {
	flight, err := s.repository.GetFlightByID(flightID)
	if err != nil {
		return err
	}

	if flight.Status == flightStatus.WAITING_PILOT && utils.ContainsUser(flight.Users, userID) {
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

	if flight.Status != flightStatus.WAITING_PILOT || currentFlight.ID != 0 {
		return errors.New("flight is not available for price proposal")
	}

	userRepository := repositories.NewUserRepository(database.DB)

	user, err := userRepository.GetById(userID)
	if err != nil {
		return err
	}

	if len(user.Vehicles) == 0 {
		return errors.New("user has no vehicles")
	}

	var vehicleId int
	var selectedVehicleID *int
	for _, vehicle := range user.Vehicles {
		if vehicle.IsSelected != nil && *vehicle.IsSelected {
			selectedVehicleID = &vehicle.ID
			break
		}
	}

	if selectedVehicleID == nil {
		return errors.New("user has no selected vehicle")
	} else {
		vehicleId = *selectedVehicleID
	}

	flight.Status = flightStatus.WAITING_PROPOSAL_APPROVAL
	flight.Price = &input.Price
	flight.PilotID = &userID
	flight.VehicleID = &vehicleId
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

	if input.Choice == "accepted" {
		payment, err := repositories.NewPaymentRepository(database.DB).GetById(userID, input.FlightId)
		if err != nil || payment.ID == 0 {
			return err
		}
	}

	if flight.Status != flightStatus.WAITING_PROPOSAL_APPROVAL || (utils.NotContainsUser(flight.Users, userID) && (flight.PilotID == nil || *flight.PilotID != userID)) {
		return errors.New("flight is not available for proposal choice")
	}

	if input.Choice == "accepted" && utils.ContainsUser(flight.Users, userID) {
		flight.Status = flightStatus.WAITING_TAKEOFF
	} else if input.Choice == "rejected" {
		flight.Status = flightStatus.WAITING_PILOT
		flight.PilotID = nil
		flight.Price = nil
		flight.VehicleID = nil
		flight.Pilot = models.User{}
		flight.Vehicle = models.Vehicle{}
	}

	_, err = s.repository.UpdateFlight(flight)

	if err != nil {
		return err
	}

	return nil
}

func (s *FlightService) FlightTakeoff(flightID int, pilotId int) error {
	flight, err := s.repository.GetFlightByID(flightID)
	if err != nil {
		return err
	}

	flightPilotId := flight.PilotID
	if flightPilotId == nil {
		return errors.New("flight has no pilot assigned")
	}

	if flight.Status != flightStatus.WAITING_TAKEOFF || *flightPilotId != pilotId {
		return errors.New("flight is not available for takeoff")
	}

	flight.Status = flightStatus.IN_PROGRESS

	_, err = s.repository.UpdateFlight(flight)

	if err != nil {
		return err
	}

	return nil
}

func (s *FlightService) PilotPositionUpdate(input inputs.InputPilotPositionUpdate, pilotId int) (responses.ResponsePilotPositionUpdate, error) {
	flight, err := s.repository.GetFlightByID(input.FlightId)
	if err != nil {
		return responses.ResponsePilotPositionUpdate{}, err
	}

	flightPilotId := flight.PilotID
	if flightPilotId == nil {
		return responses.ResponsePilotPositionUpdate{}, errors.New("flight has no pilot assigned")
	}

	if (flight.Status != flightStatus.IN_PROGRESS && flight.Status != flightStatus.WAITING_TAKEOFF) || *flightPilotId != pilotId {
		return responses.ResponsePilotPositionUpdate{}, errors.New("flight is not available for position update")
	}

	estimatedFlightTime, err := s.EstimateFlightTimeInHour(input.FlightId, utils.Position{
		Latitude:  input.Latitude,
		Longitude: input.Longitude,
	})
	if err != nil {
		return responses.ResponsePilotPositionUpdate{}, err
	}

	totalDistance := utils.ComputeDistanceInNauticalMiles(
		utils.Position{
			Latitude:  flight.DepartureLatitude,
			Longitude: flight.DepartureLongitude,
		},
		utils.Position{
			Latitude:  flight.ArrivalLatitude,
			Longitude: flight.ArrivalLongitude,
		},
	)

	remainingDistance := utils.ComputeDistanceInNauticalMiles(
		utils.Position{
			Latitude:  input.Latitude,
			Longitude: input.Longitude,
		},
		utils.Position{
			Latitude:  flight.ArrivalLatitude,
			Longitude: flight.ArrivalLongitude,
		},
	)

	response := responses.ResponsePilotPositionUpdate{
		Latitude:            input.Latitude,
		Longitude:           input.Longitude,
		EstimatedFlightTime: estimatedFlightTime,
		TotalDistance:       totalDistance,
		RemainingDistance:   remainingDistance,
	}

	return response, nil
}

func (s *FlightService) FlightLanding(flightID int, pilotId int) error {
	flight, err := s.repository.GetFlightByID(flightID)
	if err != nil {
		return err
	}

	flightPilotId := flight.PilotID
	if flightPilotId == nil {
		return errors.New("flight has no pilot assigned")
	}

	if flight.Status != flightStatus.IN_PROGRESS || *flightPilotId != pilotId {
		return errors.New("flight is not available for landing")
	}

	flight.Status = flightStatus.FINISHED

	_, err = s.repository.UpdateFlight(flight)
	if err != nil {
		return err
	}

	ratingRepository := repositories.NewRatingRepository(database.DB)

	for _, user := range flight.Users {
		rating := models.Rating{
			UserID:   user.ID,
			PilotID:  pilotId,
			FlightID: flightID,
			Status:   "waiting_for_review",
		}

		_, err := ratingRepository.CreateRating(rating)
		if err != nil {
			return err
		}
	}

	return nil
}

func (s *FlightService) CancelFlight(flightID int, userID int) error {
	flight, err := s.repository.GetFlightByID(flightID)
	if err != nil {
		return err
	}

	if (flight.Status != flightStatus.WAITING_PILOT && flight.Status != flightStatus.WAITING_TAKEOFF && flight.Status != flightStatus.WAITING_PROPOSAL_APPROVAL) || (utils.NotContainsUser(flight.Users, userID) && *flight.PilotID != userID) {
		return errors.New("flight is not available for cancel")
	}

	flight.Status = flightStatus.CANCELLED
	flight.PilotID = nil
	flight.Price = nil
	flight.VehicleID = nil

	_, err = s.repository.UpdateFlight(flight)

	if err != nil {
		return err
	}

	return nil
}

func (s *FlightService) EstimateFlightTimeInHour(flightID int, pilotPosition utils.Position) (float64, error) {
	flight, err := s.repository.GetFlightByID(flightID)
	if err != nil {
		return 0, err
	}

	arrivalPosition := utils.Position{
		Latitude:  flight.ArrivalLatitude,
		Longitude: flight.ArrivalLongitude,
	}

	distanceInNauticalMiles := utils.ComputeDistanceInNauticalMiles(pilotPosition, arrivalPosition)

	aircraftSpeed := flight.Vehicle.CruiseSpeed

	estimatedTimeInHour := distanceInNauticalMiles / aircraftSpeed

	return math.Round(estimatedTimeInHour*100) / 100, nil
}
