package routes

import (
	"backend/database"
	"backend/handlers"
	"backend/middlewares"

	"github.com/gin-gonic/gin"
)

func initUserRoutes(api *gin.RouterGroup) {

	userHandler := handlers.GetUser(database.DB)

	api = api.Group("/users")
	api.POST("", userHandler.Register)
	api.POST("/login", userHandler.Login)
	api.POST("/pilot", userHandler.RegisterPilot)

	// api = protected.Group("/user")
	api.GET("/me", middlewares.IsAuth(), userHandler.CurrentUser)
	api.GET("", middlewares.IsAdminAuth(), userHandler.GetAll)
}
