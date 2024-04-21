package main

import (
	"backend/database"
	"backend/routes"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"

	_ "backend/docs"

	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

//	@title			Backend AirFleet
//	@version		1.0
//	@description	this is the go project.

// @BasePath					/api
//
// @securityDefinitions.apikey	BearerAuth
// @in							header
// @name						Authorization

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("err loading: %v", err)
	}

	database.OpenConnection()
	gin.SetMode(os.Getenv("GIN_MODE"))
	router := gin.Default()
	routes.InitRoutes(router)

	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	router.Run(":3001")
}
