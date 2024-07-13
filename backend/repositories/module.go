package repositories

import (
	"backend/models"
	"gorm.io/gorm"
)

type ModuleRepositoryInterface interface {
	UpdateModule(module models.Module) (models.Module, error)
	GetAllModules(filters map[string]interface{}) ([]models.Module, error)
	GetModule(filters map[string]interface{}) (models.Module, error)
	GetModuleByID(moduleID int) (models.Module, error)
}

type ModuleRepository struct {
	db *gorm.DB
}

func NewModuleRepository(db *gorm.DB) *ModuleRepository {
	return &ModuleRepository{db}
}

func (r *ModuleRepository) UpdateModule(module models.Module) (models.Module, error) {
	err := r.db.Save(&module).Error
	if err != nil {
		return module, err
	}

	return module, nil
}

func (r *ModuleRepository) GetAllModules(filters map[string]interface{}) ([]models.Module, error) {
	var modules []models.Module
	query := r.db

	for key, value := range filters {
		query = query.Where(key+" = ?", value)
	}

	err := query.Find(&modules).Error
	if err != nil {
		return nil, err
	}

	return modules, nil
}

func (r *ModuleRepository) GetModule(filters map[string]interface{}) (models.Module, error) {
	var module models.Module
	query := r.db

	for key, value := range filters {
		query = query.Where(key+" = ?", value)
	}

	err := query.First(&module).Error
	if err != nil {
		return module, err
	}

	return module, nil
}

func (r *ModuleRepository) GetModuleByID(moduleID int) (models.Module, error) {
	var module models.Module
	err := r.db.Where("id = ?", moduleID).First(&module).Error
	if err != nil {
		return module, err
	}

	return module, nil
}
