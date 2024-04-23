package repositories

import (
	"backend/entities"
	"gorm.io/gorm"
)

type Repository interface {
	Create(file entities.File) (entities.File, error)
}

type repository struct {
	db *gorm.DB
}

func NewFileRepository(db *gorm.DB) *repository {
	return &repository{db}
}

func (r *repository) Create(file entities.File) (entities.File, error) {
	err := r.db.Create(&file).Error
	if err != nil {
		return file, err
	}
	return file, nil
}
