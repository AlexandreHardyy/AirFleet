package main

import (
	"backend/database"
	"backend/routes"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("err loading: %v", err)
	}

	db := database.OpenConnection()
	gin.SetMode(os.Getenv("GIN_MODE"))
	router := gin.Default()
	routes.InitRoutes(router, db)

	router.Run(":3001")

}
