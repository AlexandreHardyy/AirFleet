package routes

import (
	"backend/database"
	"backend/handlers"
	"backend/middlewares"

	"github.com/gin-gonic/gin"
)

func initProposalRoutes(api *gin.RouterGroup) {

	proposalHandler := handlers.GetProposalHandler(database.DB)

	api = api.Group("/proposals")
	api.GET("", middlewares.IsAdminAuth(), proposalHandler.GetAllProposal)
	api.GET("/:id", middlewares.IsAuth(), proposalHandler.GetProposal)
	api.POST("", middlewares.IsAuth(), proposalHandler.CreateProposal)
	api.DELETE("/:id", middlewares.IsPilotAuth(), proposalHandler.DeleteProposal)
}
