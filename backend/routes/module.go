package routes

import (
	"backend/database"
	"backend/handlers"
	"backend/middlewares"
	"github.com/gin-gonic/gin"
)

func InitModuleRoutes(api *gin.RouterGroup) {
	moduleHandler := handlers.GetModuleHandler(database.DB)

	api = api.Group("/modules")

	api.PUT("/:id", middlewares.IsAdminAuth(), moduleHandler.Update)
	api.GET("", middlewares.IsAdminAuth(), moduleHandler.GetAllModules)
	api.GET("/name/:name", middlewares.IsAuth(), moduleHandler.GetModuleByName)
}
