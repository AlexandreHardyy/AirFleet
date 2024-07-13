package services

import (
	"backend/models"
	"backend/repositories"
)

type IMonitoringLogService interface {
	Create(log models.MonitoringLog) (models.MonitoringLog, error)
	GetAll() ([]models.MonitoringLog, error)
}

type MonitoringLogService struct {
	repository repositories.IMonitoringLogRepository
}

func NewMonitoringLogService(r repositories.IMonitoringLogRepository) *MonitoringLogService {
	return &MonitoringLogService{r}
}

func (s *MonitoringLogService) Create(log models.MonitoringLog) (models.MonitoringLog, error) {
	log, err := s.repository.Create(log)

	return log, err
}

func (s *MonitoringLogService) GetAll() ([]models.MonitoringLog, error) {
	logs, err := s.repository.FindAll()
	if err != nil {
		return logs, err
	}
	return logs, nil
}
