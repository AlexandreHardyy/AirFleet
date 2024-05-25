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
	api.GET("", middlewares.IsAdminAuth(), vehicleHandler.GetAll)
	api.GET("/me", middlewares.IsAuth(), vehicleHandler.GetAllMe)
	api.GET("/:id", middlewares.IsAuth(), vehicleHandler.VehcileById)
	api.POST("", middlewares.IsAuth(), vehicleHandler.CreateVehicle)
	api.DELETE("/:id", middlewares.IsAuth(), vehicleHandler.DeleteVehicle)
	api.PATCH("/:id", middlewares.IsAuth(), vehicleHandler.UpdateVehicle)
}
