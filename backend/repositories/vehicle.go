package repositories

import (
	"backend/models"
	"backend/responses"
	"errors"

	"gorm.io/gorm"
)

type VehicleRepository interface {
	Create(vehicle models.Vehicle) (models.Vehicle, error)
	FindAll() ([]responses.Vehicle, error)
	FindAllMe(userID int) ([]responses.Vehicle, error)
	GetById(id int) (models.Vehicle, error)
	Delete(id int) error
	Update(id int, vehicle models.Vehicle) (models.Vehicle, error)
}

type vehicleRepository struct {
	db *gorm.DB
}

func NewVehicleRepository(db *gorm.DB) *vehicleRepository {
	return &vehicleRepository{db}
}

func (r *vehicleRepository) Create(vehicle models.Vehicle) (models.Vehicle, error) {

	userErr := r.db.Where(&models.Vehicle{Matriculation: vehicle.Matriculation}).First(&vehicle).Error
	if userErr == nil {
		return vehicle, errors.New("this vehicle already exists")
	}
	err := r.db.Create(&vehicle).Error
	if err != nil {
		return vehicle, err
	}
	return vehicle, nil
}

func (r *vehicleRepository) FindAll() ([]responses.Vehicle, error) {
	vehicles := []responses.Vehicle{}
	err := r.db.Model(&models.Vehicle{}).Find(&vehicles).Error
	if err != nil {
		return vehicles, err
	}

	return vehicles, nil
}

func (r *vehicleRepository) FindAllMe(userID int) ([]responses.Vehicle, error) {
	vehicles := []responses.Vehicle{}
	err := r.db.Model(&models.Vehicle{}).Where(&models.Vehicle{UserID: userID}).Find(&vehicles).Error
	if err != nil {
		return vehicles, err
	}

	return vehicles, nil

}

func (r *vehicleRepository) GetById(id int) (models.Vehicle, error) {
	vehicle := models.Vehicle{}
	err := r.db.Preload("User").Where(&models.Vehicle{ID: id}).First(&vehicle).Error
	if err != nil {
		return vehicle, err
	}

	return vehicle, nil
}

func (r *vehicleRepository) Delete(id int) error {
	vehicle := models.Vehicle{}
	err := r.db.Where(&models.Vehicle{ID: id}).First(&vehicle).Error
	if err != nil {
		return err
	}
	err = r.db.Delete(&vehicle).Error
	if err != nil {
		return err
	}
	return nil
}

func (r *vehicleRepository) Update(id int, vehicle models.Vehicle) (models.Vehicle, error) {
	vehicle.ID = id
	err := r.db.Where(&models.Vehicle{ID: id}).Updates(&vehicle).Error
	if err != nil {
		return vehicle, err
	}
	return vehicle, nil
}
