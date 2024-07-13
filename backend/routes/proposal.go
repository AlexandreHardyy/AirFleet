package routes

import (
	"backend/database"
	"backend/handlers"
	"backend/middlewares"

	"github.com/gin-gonic/gin"
)

func InitProposalRoutes(api *gin.RouterGroup) {

	proposalHandler := handlers.GetProposalHandler(database.DB)

	api = api.Group("/proposals")
	api.GET("", middlewares.IsAuth(), proposalHandler.GetAllProposal)
	api.GET("/me", middlewares.IsAuth(), proposalHandler.GetMyProposals)
	api.GET("/:id", middlewares.IsAuth(), proposalHandler.GetProposal)
	api.POST("", middlewares.IsPilotAuth(), proposalHandler.CreateProposal)
	api.PATCH("/:id", middlewares.IsPilotAuth(), proposalHandler.UpdateProposal)
	api.DELETE("/:id", middlewares.IsPilotAuth(), proposalHandler.DeleteProposal)
	api.PATCH("/:id/join", middlewares.IsAuth(), proposalHandler.JoinProposal)
	api.PATCH("/:id/leave", middlewares.IsAuth(), proposalHandler.LeaveProposal)
}
