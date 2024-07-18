package inputs

import "time"

type FilterPropsal struct {
	MaxPrice              float64 `form:"max_price"`
	LeftAvailableSeats    int     `form:"left_available_seats"`
	DeparturePositionLat  float64 `form:"departure_position_lat"`
	DeparturePositionLong float64 `form:"departure_position_long"`
	ArrivalPositionLat    float64 `form:"arrival_position_lat"`
	ArrivalPositionLong   float64 `form:"arrival_position_long"`
	Proximity             int     `form:"proximity"`
}

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
