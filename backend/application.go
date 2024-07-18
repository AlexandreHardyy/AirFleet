package main

import (
	"backend/database"
	_ "backend/docs"
	"backend/routes"
	"backend/services/brevo"
	"backend/websocket"
	"github.com/gin-gonic/gin"
	socketio "github.com/googollee/go-socket.io"
	"github.com/joho/godotenv"
	"github.com/stripe/stripe-go/v79"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"log"
	"os"

	"github.com/gin-contrib/cors"
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

	stripe.Key = os.Getenv("PRIVATE_API_KEY_STRIPE")
	brevo.InitBrevoClient()

	database.OpenConnection()

	ginMode := os.Getenv("GIN_MODE")
	if ginMode == "" {
		ginMode = "release"
	}
	gin.SetMode(ginMode)
	router := gin.Default()

	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	config.AllowHeaders = []string{"Origin", "Content-Length", "Content-Type", "Authorization"}
	router.Use(cors.New(config))

	socketIoServer := socketio.NewServer(nil)

	defer socketIoServer.Close()

	routes.InitRoutes(router)
	websocket.InitWebSocket(socketIoServer)

	router.GET("/socket.io/*any", gin.WrapH(socketIoServer))
	router.POST("/socket.io/*any", gin.WrapH(socketIoServer))

	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	port := os.Getenv("PORT")
	if port == "" {
		port = "5000"
	}
	err = router.Run(":" + port)
	log.Panic(err)
}
