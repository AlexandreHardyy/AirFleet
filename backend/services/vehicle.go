package services

import (
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
)

type VehicleService interface {
	Create(vehicle inputs.CreateVehicle) (responses.Vehicle, error)
	GetAll() ([]responses.Vehicle, error)
	GetById(id int) (models.Vehicle, error)
	Delete(id int) error
	Update(id int, vehicle inputs.UpdateVehicle) (models.Vehicle, error)
}

type vehiclSservice struct {
	repository repositories.VehicleRepository
}

func NewVehicleService(r repositories.VehicleRepository) *vehiclSservice {
	return &vehiclSservice{r}
}

func (s *vehiclSservice) Create(input inputs.CreateVehicle) (responses.Vehicle, error) {
	var vehicle = models.Vehicle{
		ModelName:     input.ModelName,
		Matriculation: input.Matriculation,
		Seat:          input.Seat,
		Type:          input.Type,
		UserID:        input.UserID,
	}

	vehicle, err := s.repository.Create(vehicle)
	formattedVehicle := responses.Vehicle{
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

func (s *vehiclSservice) GetAll() ([]responses.Vehicle, error) {
	vehicle, err := s.repository.FindAll()
	if err != nil {
		return vehicle, err
	}
	return vehicle, nil
}

func (s *vehiclSservice) GetById(id int) (models.Vehicle, error) {
	vehicle, err := s.repository.GetById(id)
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

func (s *vehiclSservice) Update(id int, input inputs.UpdateVehicle) (models.Vehicle, error) {
	var vehicle = models.Vehicle{
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
