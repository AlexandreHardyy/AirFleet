package main

import (
	"backend/database"
	"backend/routes"
	"backend/services/brevo"
	"backend/websocket"
	"github.com/gin-contrib/cors"
	"log"
	"os"

	socketio "github.com/googollee/go-socket.io"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"

	_ "backend/docs"

	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

//	@title			Backend AirFleet
//	@version		1.0
//	@description	this is the go project.

//	@BasePath					/api
//
//	@securityDefinitions.apikey	BearerAuth
//	@in							header
//	@name						Authorization

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("err loading: %v", err)
	}
	brevo.InitBrevoClient()

	database.OpenConnection()

	gin.SetMode(os.Getenv("GIN_MODE"))
	router := gin.Default()

	socketIoServer := socketio.NewServer(nil)

	defer socketIoServer.Close()

	routes.InitRoutes(router)
	websocket.InitWebSocket(socketIoServer)

	router.GET("/socket.io/*any", gin.WrapH(socketIoServer))
	router.POST("/socket.io/*any", gin.WrapH(socketIoServer))

	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	router.Use(cors.New(config))
	router.Run(":3001")
}
