package responses

import "time"

type ResponseAirport struct {
	Name      string  `json:"name"`
	Address   string  `json:"address"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type ResponseFlight struct {
	ID        int              `json:"id"  binding:"required"`
	Status    string           `json:"status"  binding:"required"`
	Price     *float64         `json:"price"`
	Users     []ListUser       `json:"users"`
	PilotID   *int             `json:"pilot_id"`
	VehicleID *int             `json:"vehicle_id"`
	Departure ResponseAirport  `json:"departure" binding:"required"`
	Arrival   ResponseAirport  `json:"arrival" binding:"required"`
	CreatedAt time.Time        `json:"created_at"`
	UpdatedAt time.Time        `json:"updated_at"`
	Pilot     *ListUser        `json:"pilot"`
	Vehicle   *ResponseVehicle `json:"vehicle"`
}

// WEBSOCKET

// DEPRECATED
type ResponsePilotPosition struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type ResponsePilotPositionUpdate struct {
	Latitude            float64 `json:"latitude"`
	Longitude           float64 `json:"longitude"`
	EstimatedFlightTime float64 `json:"estimated_flight_time"`
	TotalDistance       float64 `json:"total_distance"`
	RemainingDistance   float64 `json:"remaining_distance"`
}
