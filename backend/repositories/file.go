package repositories

import (
	"backend/models"

	"gorm.io/gorm"
)

type Repository interface {
	Create(file models.File) (models.File, error)
	Update(path string, userId int) (models.File, error)
}

type repository struct {
	db *gorm.DB
}

func NewFileRepository(db *gorm.DB) *repository {
	return &repository{db}
}

func (r *repository) Create(file models.File) (models.File, error) {
	err := r.db.Create(&file).Error
	if err != nil {
		return file, err
	}
	return file, nil
}

func (r *repository) Update(path string, userId int) (models.File, error) {

	var image models.File
	err := r.db.Where(models.File{Type: "profile"}).Find(&image).Error
	if err != nil {
		return image, err
	}

	image.Path = path
	image.Type = "profile"
	image.UserID = userId

	err = r.db.Save(&image).Error
	if err != nil {
		return image, err
	}
	return image, nil
}
