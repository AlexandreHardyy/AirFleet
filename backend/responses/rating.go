package responses

import "time"

type ResponseRating struct {
	ID        int       `json:"id"`
	Rating    float64   `json:"rating"`
	Comment   string    `json:"comment"`
	Status    string    `json:"status"`
	PilotID   int       `json:"pilot_id"`
	Pilot     ListUser  `json:"pilot"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
