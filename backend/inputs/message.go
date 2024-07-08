package inputs

// WEBSOCKET

type InputCreateMessage struct {
	FlightID int    `json:"flightId" binding:"required"`
	Content  string `json:"content" binding:"required"`
}
