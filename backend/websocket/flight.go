package websocket

import (
	"backend/database"
	"backend/handlers"
	socketio "github.com/googollee/go-socket.io"
	"log"
)

func InitFlightSession(socketIoServer *socketio.Server) {
	flightSocketHandler := handlers.GetFlightSocketHandler(database.DB, socketIoServer)
	messageSocketHandler := handlers.GetMessageSocketHandler(database.DB, socketIoServer)

	socketIoServer.OnEvent("/flights", "createSession", flightSocketHandler.CreateFlightSession)

	socketIoServer.OnEvent("/flights", "makeFlightProposal", flightSocketHandler.MakeFlightPriceProposal)

	socketIoServer.OnEvent("/flights", "flightProposalChoice", flightSocketHandler.FlightProposalChoice)

	socketIoServer.OnEvent("/flights", "flightTakeoff", flightSocketHandler.FlightTakeoff)

	socketIoServer.OnEvent("/flights", "pilotPositionUpdate", flightSocketHandler.PilotPositionUpdate)

	socketIoServer.OnEvent("/flights", "flightLanding", flightSocketHandler.FlightLanding)

	socketIoServer.OnEvent("/flights", "cancelFlight", flightSocketHandler.CancelFlight)

	socketIoServer.OnEvent("/flights", "newMessageBack", messageSocketHandler.CreateMessage)

	socketIoServer.OnEvent("/flights", "flightSimulation", flightSocketHandler.StartAndCompleteFlight)

	socketIoServer.OnEvent("/flights", "flightSimulationStop", flightSocketHandler.FlightSimulationStop)

	socketIoServer.OnEvent("/flights", "bye", func(s socketio.Conn) {
		err := s.Close()
		if err != nil {
			return
		}
	})

	socketIoServer.OnDisconnect("/", func(s socketio.Conn, reason string) {
		log.Println("closed", reason)
		flightSocketHandler.StopGoroutine(s.ID())
	})

	socketIoServer.OnError("/flights", func(s socketio.Conn, e error) {
		log.Println("meet error:", e)
	})
}
