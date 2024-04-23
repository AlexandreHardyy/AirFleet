package repositories

import (
	"backend/entities"
	"backend/responses"
	"errors"
	"gorm.io/gorm"
)

type VehicleRepository interface {
	CreateVehicle(vehicle entities.Vehicle) (entities.Vehicle, error)
	FindAllVehicles() ([]responses.ResponseVehicle, error)
	GetVehicleById(id int) (entities.Vehicle, error)
	Delete(id int) error
	Update(id int, vehicle entities.Vehicle) (entities.Vehicle, error)
}

type vehicleRepository struct {
	db *gorm.DB
}

func NewVehicleRepository(db *gorm.DB) *vehicleRepository {
	return &vehicleRepository{db}
}

func (r *vehicleRepository) CreateVehicle(vehicle entities.Vehicle) (entities.Vehicle, error) {

	userErr := r.db.Where(&entities.Vehicle{Matriculation: vehicle.Matriculation}).First(&vehicle).Error
	if userErr == nil {
		return vehicle, errors.New("this vehicle already exists")
	}
	err := r.db.Create(&vehicle).Error
	if err != nil {
		return vehicle, err
	}
	return vehicle, nil
}

func (r *vehicleRepository) FindAllVehicles() ([]responses.ResponseVehicle, error) {
	vehicles := []responses.ResponseVehicle{}
	err := r.db.Model(&entities.Vehicle{}).Find(&vehicles).Error
	if err != nil {
		return vehicles, err
	}

	return vehicles, nil
}

func (r *vehicleRepository) GetVehicleById(id int) (entities.Vehicle, error) {
	vehicle := entities.Vehicle{}
	err := r.db.Preload("User").Where(&entities.Vehicle{ID: id}).First(&vehicle).Error
	if err != nil {
		return vehicle, err
	}

	return vehicle, nil
}

func (r *vehicleRepository) Delete(id int) error {
	vehicle := entities.Vehicle{}
	err := r.db.Where(&entities.Vehicle{ID: id}).First(&vehicle).Error
	if err != nil {
		return err
	}
	err = r.db.Delete(&vehicle).Error
	if err != nil {
		return err
	}
	return nil
}

func (r *vehicleRepository) Update(id int, vehicle entities.Vehicle) (entities.Vehicle, error) {
	vehicle.ID = id
	err := r.db.Where(&entities.Vehicle{ID: id}).Updates(&vehicle).Error
	if err != nil {
		return vehicle, err
	}
	return vehicle, nil
}
