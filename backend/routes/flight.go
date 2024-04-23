package routes

import (
	"backend/database"
	"backend/handlers"
	"github.com/gin-gonic/gin"
)

func InitFlightRoutes(api *gin.RouterGroup) {
	flightHandler := handlers.GetFlightHandler(database.DB)

	api = api.Group("/flights")

	api.GET("", flightHandler.GetAll)

	api.POST("", flightHandler.Create)
}
