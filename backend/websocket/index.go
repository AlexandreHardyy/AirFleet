package websocket

import (
	"backend/utils/token"
	socketio "github.com/googollee/go-socket.io"
	"log"
)

func InitWebSocket(socketIoServer *socketio.Server) {
	socketIoServer.OnConnect("/", func(s socketio.Conn) error {
		tokenString := s.RemoteHeader().Get("Bearer")

		err := token.CheckToken(tokenString)
		if err != nil {
			return err
		}

		s.SetContext("")
		log.Println("connected:", s.ID())
		return nil
	})

	socketIoServer.OnDisconnect("/", func(s socketio.Conn, reason string) {
		log.Println("closed", reason)
	})

	go func() {
		if err := socketIoServer.Serve(); err != nil {
			log.Fatalf("websocket listen error: %s\n", err)
		}
	}()

	InitFlightSession(socketIoServer)
}
