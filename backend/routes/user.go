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
	api.GET("/validate/:token", userHandler.ValidateAccount)
	api.POST("/pilot", userHandler.RegisterPilot)

	api.PATCH("/:id", middlewares.IsAdminAuth(), userHandler.Update)
	api.PATCH("/pilot-validate/:id", middlewares.IsAdminAuth(), userHandler.ValidatePilotAccount)

	api.GET("/me", middlewares.IsAuth(), userHandler.CurrentUser)
	api.GET("", middlewares.IsAdminAuth(), userHandler.GetAll)

	api.PUT("/:id", middlewares.IsAdminAuth(), userHandler.Update)
	api.DELETE("/:id", middlewares.IsAdminAuth(), userHandler.Delete)
}
