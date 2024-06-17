package inputs

type Airport struct {
	Name      string  `json:"name"`
	Address   string  `json:"address"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type InputCreateFlight struct {
	Departure Airport `json:"departure" binding:"required"`
	Arrival   Airport `json:"arrival" binding:"required"`
}

// WEBSOCKET

type InputCreateFlightProposal struct {
	FlightId int     `json:"flightId" binding:"required"`
	Price    float64 `json:"price" binding:"required"`
}

type InputFlightProposalChoice struct {
	FlightId int    `json:"flightId" binding:"required"`
	Choice   string `json:"choice" binding:"required"`
}

type InputPilotPositionUpdate struct {
	FlightId  int     `json:"flightId" binding:"required"`
	Latitude  float64 `json:"latitude" binding:"required"`
	Longitude float64 `json:"longitude" binding:"required"`
}
