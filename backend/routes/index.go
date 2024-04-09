package routes

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func InitRoutes(router *gin.Engine, db *gorm.DB) {

	api := router.Group("/api")

	// protected := router.Group("/api/protected")
	// protected.Use(middlewares.JwtAuthMiddleware())

	initUserRoutes(api, db)
}
