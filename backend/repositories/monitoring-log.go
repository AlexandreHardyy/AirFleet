package repositories

import (
	"backend/database"
	"backend/models"

	"gorm.io/gorm"
)

type IMonitoringLogRepository interface {
	Create(monitoringLog models.MonitoringLog) (models.MonitoringLog, error)
	FindAll() ([]models.MonitoringLog, error)
}

type MonitoringLogRepository struct {
	db *gorm.DB
}

func NewMonitoringLogRepository(db *gorm.DB) *MonitoringLogRepository {
	return &MonitoringLogRepository{db}
}

func (r *MonitoringLogRepository) Create(monitoringLog models.MonitoringLog) (models.MonitoringLog, error) {
	err := r.db.Create(&monitoringLog).Error
	if err != nil {
		return monitoringLog, err
	}
	return monitoringLog, nil
}

func CreateMonitoringLog(monitoringLog models.MonitoringLog) (models.MonitoringLog, error) {
	repository := NewMonitoringLogRepository(database.DB)

	return repository.Create(monitoringLog)
}

func (r *MonitoringLogRepository) FindAll() ([]models.MonitoringLog, error) {
	var logs []models.MonitoringLog
	err := r.db.Order("created_at DESC").Find(&logs).Error
	if err != nil {
		return logs, err
	}
	return logs, nil
}
