package inputs

import "time"

type InputCreateProposal struct {
	DepartureTime  time.Time    `json:"departureTime" binding:"required"`
	Description    string       `json:"description" binding:"required"`
	AvailableSeats int          `json:"availableSeats" binding:"required"`
	CreateFlight   CreateFlight `json:"createFlight" binding:"required"`
	Price          float64      `json:"price" binding:"required"`
	VehicleID      int          `json:"vehicleId" binding:"required"`
}

type InputUpdateProposal struct {
	DepartureTime  time.Time `json:"departureTime"`
	Description    string    `json:"description"`
	AvailableSeats int       `json:"availableSeats"`
	Price          float64   `json:"price"`
	VehicleID      int       `json:"vehicleId"`
}
