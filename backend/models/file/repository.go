package file

import (
	"gorm.io/gorm"
)

type Repository interface {
	Create(file File) (File, error)
}

type repository struct {
	db *gorm.DB
}

func NewRepository(db *gorm.DB) *repository {
	return &repository{db}
}

func (r *repository) Create(file File) (File, error) {
	err := r.db.Create(&file).Error
	if err != nil {
		return file, err
	}
	return file, nil
}
