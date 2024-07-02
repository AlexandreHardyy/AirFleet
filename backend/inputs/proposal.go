package inputs

import "time"

type InputCreateProposal struct {
	FlightId      int       `json:"flightId" binding:"required"`
	DepartureTime time.Time `json:"departureTime" binding:"required"`
	Description   string    `json:"description" binding:"required"`
}
