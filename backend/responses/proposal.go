package responses

import "time"

type ResponseProposal struct {
	ID            int            `json:"id"`
	DepartureTime time.Time      `json:"departure_time"`
	Description   string         `json:"description"`
	Flight        ResponseFlight `json:"flight"`
}
