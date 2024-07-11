package routes

import (
	"github.com/gin-gonic/gin"
)

func InitRoutes(router *gin.Engine) {
	api := router.Group("/api")

	// protected := router.Group("/api/protected")
	// protected.Use(middlewares.JwtAuthMiddleware())

	initUserRoutes(api)
	initVehicleRoutes(api)
	InitFlightRoutes(api)
	InitMessageRoutes(api)
	InitRatingRoutes(api)
	InitRatingRoutes(api)
}
