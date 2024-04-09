package routes

import (
	"backend/handlers"
	"backend/middlewares"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func initUserRoutes(api *gin.RouterGroup, db *gorm.DB) {

	userHandler := handlers.GetUser(db)

	api = api.Group("/users")
	api.POST("", userHandler.Register)
	api.POST("/login", userHandler.Login)

	// api = protected.Group("/user")
	api.GET("/me", middlewares.IsAuth(), userHandler.CurrentUser)
	api.GET("", middlewares.IsAdminAuth(db), userHandler.GetAll)
}
