package routes

import (
	"backend/database"
	"backend/handlers"
	"backend/middlewares"
	"github.com/gin-gonic/gin"
)

func InitRatingRoutes(api *gin.RouterGroup) {
	ratingHandler := handlers.GetRatingHandler(database.DB)

	api = api.Group("/ratings")

	api.PUT("/:id", middlewares.IsAuth(), ratingHandler.Update)
	api.GET("/status/:status", middlewares.IsAuth(), ratingHandler.GetRatingByUserIDAndStatus)
	api.GET("/pilot/:id", middlewares.IsAuth(), ratingHandler.GetRatingsByPilotID)
	api.GET("", middlewares.IsAdminAuth(), ratingHandler.GetAllRatings)
}
