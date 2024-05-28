package websocket

import (
	"backend/database"
	"backend/handlers"
	socketio "github.com/googollee/go-socket.io"
	"log"
)

func InitFlightSession(socketIoServer *socketio.Server) {
	flightSocketHandler := handlers.GetFlightSocketHandler(database.DB, socketIoServer)

	socketIoServer.OnEvent("/flights", "createSession", flightSocketHandler.CreateFlightSession)

	socketIoServer.OnEvent("/flights", "makeFlightProposal", flightSocketHandler.MakeFlightPriceProposal)

	socketIoServer.OnEvent("/flights", "flightProposalChoice", flightSocketHandler.FlightProposalChoice)

	socketIoServer.OnEvent("/flights", "flightTakeoff", flightSocketHandler.FlightTakeoff)

	socketIoServer.OnEvent("/flights", "flightLanding", flightSocketHandler.FlightLanding)

	socketIoServer.OnEvent("/flights", "cancelFlight", flightSocketHandler.CancelFlight)

	socketIoServer.OnEvent("/flights", "bye", func(s socketio.Conn) {
		s.Close()
	})

	socketIoServer.OnError("/flights", func(s socketio.Conn, e error) {
		log.Println("meet error:", e)
	})
}
