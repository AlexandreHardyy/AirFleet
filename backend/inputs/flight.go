package inputs

type Airport struct {
	Name      string  `json:"name"`
	Address   string  `json:"address"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type NearByParams struct {
	Range     float64 `form:"range"`
	Latitude  float64 `form:"latitude" binding:"required"`
	Longitude float64 `form:"longitude" binding:"required"`
}

type CreateFlight struct {
	Departure Airport `json:"departure" binding:"required"`
	Arrival   Airport `json:"arrival" binding:"required"`
}

type FilterFlights struct {
	Status string `form:"status"`
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

type UserFlightJoinRequest struct {
	FlightId int    `json:"flightId"`
	UserId   int    `json:"userId"`
	Choice   string `json:"choice"`
}
