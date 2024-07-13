package routes

import (
	"backend/database"
	"backend/handlers"
	"backend/middlewares"

	"github.com/gin-gonic/gin"
)

func initMonitoringLogRoutes(api *gin.RouterGroup) {

	userHandler := handlers.GetMonitoringLogHandler(database.DB)

	api = api.Group("/monitoring-logs")
	api.GET("", middlewares.IsAdminAuth(), userHandler.GetAll)
}
