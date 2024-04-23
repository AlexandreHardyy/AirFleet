package responses

import (
	"time"
)

type Vehicle struct {
	ID            int       `json:"id"`
	ModelName     string    `json:"model_name"`
	Matriculation string    `json:"matriculation"`
	Seat          int       `json:"seat"`
	Type          string    `json:"type"`
	IsVerified    bool      `json:"is_verified"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}
