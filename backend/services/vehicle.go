package services

import (
	"backend/entities"
	"backend/inputs"
	"backend/repositories"
	"backend/responses"
)

type VehicleService interface {
	CreateVehicle(vehicle inputs.InputCreateVehicle) (responses.ResponseVehicle, error)
	GetAll() ([]responses.ResponseVehicle, error)
	GetById(id int) (entities.Vehicle, error)
	Delete(id int) error
	Update(id int, vehicle inputs.InputUpdateVehicle) (entities.Vehicle, error)
}

type vehiclSservice struct {
	repository repositories.VehicleRepository
}

func NewVehicleService(r repositories.VehicleRepository) *vehiclSservice {
	return &vehiclSservice{r}
}

func (s *vehiclSservice) CreateVehicle(input inputs.InputCreateVehicle) (responses.ResponseVehicle, error) {
	var vehicle = entities.Vehicle{
		ModelName:     input.ModelName,
		Matriculation: input.Matriculation,
		Seat:          input.Seat,
		Type:          input.Type,
		UserID:        input.UserID,
	}

	vehicle, err := s.repository.CreateVehicle(vehicle)
	formattedVehicle := responses.ResponseVehicle{
		ID:            vehicle.ID,
		ModelName:     vehicle.ModelName,
		Matriculation: vehicle.Matriculation,
		Seat:          vehicle.Seat,
		Type:          vehicle.Type,
		CreatedAt:     vehicle.CreatedAt,
		UpdatedAt:     vehicle.UpdatedAt,
	}
	if err != nil {
		return formattedVehicle, err
	}

	return formattedVehicle, nil
}

func (s *vehiclSservice) GetAll() ([]responses.ResponseVehicle, error) {
	vehicle, err := s.repository.FindAllVehicles()
	if err != nil {
		return vehicle, err
	}
	return vehicle, nil
}

func (s *vehiclSservice) GetById(id int) (entities.Vehicle, error) {
	vehicle, err := s.repository.GetVehicleById(id)
	if err != nil {
		return vehicle, err
	}
	return vehicle, nil
}

func (s *vehiclSservice) Delete(id int) error {
	err := s.repository.Delete(id)
	if err != nil {
		return err
	}
	return nil
}

func (s *vehiclSservice) Update(id int, input inputs.InputUpdateVehicle) (entities.Vehicle, error) {
	var vehicle = entities.Vehicle{
		ModelName:     input.ModelName,
		Matriculation: input.Matriculation,
		Seat:          input.Seat,
		Type:          input.Type,
	}
	vehicle, err := s.repository.Update(id, vehicle)
	if err != nil {
		return vehicle, err
	}
	return vehicle, nil
}
