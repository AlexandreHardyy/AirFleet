package routes

import (
	"github.com/gin-gonic/gin"
)

func InitRoutes(router *gin.Engine) {
	api := router.Group("/api")

	initUserRoutes(api)
	initVehicleRoutes(api)
	InitFlightRoutes(api)
	InitMessageRoutes(api)
	InitRatingRoutes(api)
	InitProposalRoutes(api)
	initMonitoringLogRoutes(api)
	InitModuleRoutes(api)
	initPaymentRoutes(api)
}
