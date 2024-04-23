package routes

import (
	"backend/database"
	"backend/handlers"
	"backend/middlewares"
	"github.com/gin-gonic/gin"
)

func initVehicleRoutes(api *gin.RouterGroup) {

	vehicleHandler := handlers.GetVehicle(database.DB)

	api = api.Group("/vehicles")
	api.POST("", vehicleHandler.CreateVehicle)
	api.GET("", middlewares.IsAdminAuth(), vehicleHandler.GetAll)
	api.GET("/:id", vehicleHandler.VehcileById)
	api.DELETE("/:id", vehicleHandler.DeleteVehicle)
	api.PATCH("/:id", vehicleHandler.UpdateVehicle)
}
