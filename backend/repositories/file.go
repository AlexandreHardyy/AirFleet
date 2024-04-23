package repositories

import (
	"backend/models"
	"gorm.io/gorm"
)

type Repository interface {
	Create(file models.File) (models.File, error)
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
