package routes

import (
	"backend/handlers"
	"backend/middlewares"

	"github.com/gin-gonic/gin"
)

func initPaymentRoutes(api *gin.RouterGroup) {

	api = api.Group("/payment")
	api.POST("/create-intent", middlewares.IsAuth(), handlers.CreatePaymentIntent)
	api.POST("/verify", middlewares.IsAuth(), handlers.VerifyPayment)

}
