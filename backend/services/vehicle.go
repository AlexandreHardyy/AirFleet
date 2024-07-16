package services

import (
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
)

type IVehicleService interface {
	Create(vehicle inputs.CreateVehicle, userID int) (responses.ResponseVehicle, error)
	GetAll() ([]responses.ResponseVehicle, error)
	GetAllMe(userID int) ([]responses.ResponseVehicle, error)
	GetById(id int, userID int) (responses.ResponseVehicle, error)
	Delete(id int) error
	Update(id int, vehicle inputs.UpdateVehicle) (responses.ResponseVehicle, error)
}

type VehicleService struct {
	repository repositories.VehicleRepository
}

func NewVehicleService(r repositories.VehicleRepository) *VehicleService {
	return &VehicleService{r}
}

func (s *VehicleService) Create(input inputs.CreateVehicle, userID int) (responses.ResponseVehicle, error) {
	var vehicle = models.Vehicle{
		ModelName:      input.ModelName,
		Matriculation:  input.Matriculation,
		Seat:           input.Seat,
		Type:           input.Type,
		CruiseSpeed:    input.CruiseSpeed,
		CruiseAltitude: input.CruiseAltitude,
		IsVerified:     input.IsVerified,
		UserID:         userID,
	}

	vehicle, err := s.repository.Create(vehicle)
	formattedVehicle := responses.ResponseVehicle{
		ID:             vehicle.ID,
		ModelName:      vehicle.ModelName,
		Matriculation:  vehicle.Matriculation,
		Seat:           vehicle.Seat,
		Type:           vehicle.Type,
		CruiseSpeed:    vehicle.CruiseSpeed,
		CruiseAltitude: vehicle.CruiseAltitude,
		IsVerified:     vehicle.IsVerified,
		CreatedAt:      vehicle.CreatedAt,
		UpdatedAt:      vehicle.UpdatedAt,
	}
	if err != nil {
		return formattedVehicle, err
	}

	return formattedVehicle, nil
}

func (s *VehicleService) GetAll() ([]responses.ResponseVehicle, error) {
	vehicle, err := s.repository.FindAll()
	if err != nil {
		return vehicle, err
	}
	return vehicle, nil
}

func (s *VehicleService) GetAllMe(userID int) ([]responses.ResponseVehicle, error) {
	vehicle, err := s.repository.FindAllMe(userID)
	if err != nil {
		return vehicle, err
	}
	return vehicle, nil

}

func (s *VehicleService) GetById(id int, userID int) (responses.ResponseVehicle, error) {
	vehicle, err := s.repository.GetById(id)
	if err != nil {
		return responses.ResponseVehicle{}, err
	}

	return formatVehicle(vehicle), nil
}

func (s *VehicleService) Delete(id int) error {
	err := s.repository.Delete(id)
	if err != nil {
		return err
	}
	return nil
}

func (s *VehicleService) Update(id int, input inputs.UpdateVehicle) (responses.ResponseVehicle, error) {
	var vehicle = models.Vehicle{
		ModelName:      input.ModelName,
		Matriculation:  input.Matriculation,
		Seat:           input.Seat,
		Type:           input.Type,
		CruiseSpeed:    input.CruiseSpeed,
		CruiseAltitude: input.CruiseAltitude,
		IsSelected:     input.IsSelected,
		IsVerified:     input.IsVerified,
	}

	vehicle, err := s.repository.Update(id, vehicle)
	if err != nil {
		return formatVehicle(vehicle), err
	}
	return formatVehicle(vehicle), nil
}

func formatVehicle(vehicle models.Vehicle) responses.ResponseVehicle {
	return responses.ResponseVehicle{
		ID:             vehicle.ID,
		ModelName:      vehicle.ModelName,
		Matriculation:  vehicle.Matriculation,
		Seat:           vehicle.Seat,
		Type:           vehicle.Type,
		CruiseSpeed:    vehicle.CruiseSpeed,
		CruiseAltitude: vehicle.CruiseAltitude,
		IsVerified:     vehicle.IsVerified,
		IsSelected:     *vehicle.IsSelected,
		CreatedAt:      vehicle.CreatedAt,
		UpdatedAt:      vehicle.UpdatedAt,
	}
}

func formatVehicles(vehicles []models.Vehicle) []responses.ResponseVehicle {
	var responseVehicles []responses.ResponseVehicle
	for _, vehicle := range vehicles {
		responseVehicles = append(responseVehicles, formatVehicle(vehicle))
	}
	return responseVehicles
}
