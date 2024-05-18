package responses

import "time"

type ResponseAirport struct {
	Name      string  `json:"name"`
	Address   string  `json:"address"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type ResponseFlight struct {
	ID        int             `json:"id"`
	Status    string          `json:"status"`
	Departure ResponseAirport `json:"departure" binding:"required"`
	Arrival   ResponseAirport `json:"arrival" binding:"required"`
	CreatedAt time.Time       `json:"created_at"`
	UpdatedAt time.Time       `json:"updated_at"`
}
