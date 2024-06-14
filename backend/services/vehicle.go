package services

import (
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
)

type VehicleService interface {
	Create(vehicle inputs.CreateVehicle, userID int) (responses.Vehicle, error)
	GetAll() ([]responses.Vehicle, error)
	GetAllMe(userID int) ([]responses.Vehicle, error)
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

func (s *vehiclSservice) Create(input inputs.CreateVehicle, userID int) (responses.Vehicle, error) {
	var vehicle = models.Vehicle{
		ModelName:      input.ModelName,
		Matriculation:  input.Matriculation,
		Seat:           input.Seat,
		Type:           input.Type,
		CruiseSpeed:    input.CruiseSpeed,
		CruiseAltitude: input.CruiseAltitude,
		UserID:         userID,
	}

	vehicle, err := s.repository.Create(vehicle)
	formattedVehicle := responses.Vehicle{
		ID:             vehicle.ID,
		ModelName:      vehicle.ModelName,
		Matriculation:  vehicle.Matriculation,
		Seat:           vehicle.Seat,
		Type:           vehicle.Type,
		CruiseSpeed:    vehicle.CruiseSpeed,
		CruiseAltitude: vehicle.CruiseAltitude,
		CreatedAt:      vehicle.CreatedAt,
		UpdatedAt:      vehicle.UpdatedAt,
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

func (s *vehiclSservice) GetAllMe(userID int) ([]responses.Vehicle, error) {
	vehicle, err := s.repository.FindAllMe(userID)
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
		ModelName:      input.ModelName,
		Matriculation:  input.Matriculation,
		Seat:           input.Seat,
		Type:           input.Type,
		CruiseSpeed:    input.CruiseSpeed,
		CruiseAltitude: input.CruiseAltitude,
	}
	vehicle, err := s.repository.Update(id, vehicle)
	if err != nil {
		return vehicle, err
	}
	return vehicle, nil
}
