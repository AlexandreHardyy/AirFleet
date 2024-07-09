package routes

import (
	"backend/database"
	"backend/handlers"
	"backend/middlewares"
	"github.com/gin-gonic/gin"
)

func InitMessageRoutes(api *gin.RouterGroup) {
	messageHandler := handlers.GetMessageHandler(database.DB)

	api = api.Group("/messages")

	api.GET("", middlewares.IsAuth(), messageHandler.GetAll)
	api.GET("/flight/:flightId", middlewares.IsAuth(), messageHandler.GetAllByFlightID)
}
