package routes

import (
	"backend/database"
	"backend/handlers"
	"backend/middlewares"
	"github.com/gin-gonic/gin"
)

func InitFlightRoutes(api *gin.RouterGroup) {
	flightHandler := handlers.GetFlightHandler(database.DB)

	api = api.Group("/flights")

	api.GET("", flightHandler.GetAll)

	api.POST("", middlewares.IsAuth(), flightHandler.Create)

	api.GET("/current", middlewares.IsAuth(), flightHandler.GetCurrentFlight)
}
