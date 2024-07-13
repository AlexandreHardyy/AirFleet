package handlers

import (
	"backend/repositories"
	"backend/services"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type MonitoringLogHandler struct {
	monitoringLogService services.IMonitoringLogService
}

func GetMonitoringLogHandler(db *gorm.DB) *MonitoringLogHandler {
	monitoringLogRepository := repositories.NewMonitoringLogRepository(db)
	monitoringLogService := services.NewMonitoringLogService(monitoringLogRepository)
	return newMonitoringLogHandler(monitoringLogService)
}

func newMonitoringLogHandler(monitoringLogService services.IMonitoringLogService) *MonitoringLogHandler {
	return &MonitoringLogHandler{monitoringLogService}
}

func (h *MonitoringLogHandler) GetAll(c *gin.Context) {
	logs, err := h.monitoringLogService.GetAll()
	if err != nil {
		c.JSON(500, Response{
			Message: err.Error(),
		})
		return
	}

	c.JSON(200, logs)
}
