package responses

import (
	"backend/models"
	"time"
)

type Login struct {
	Token string `json:"token"`
}

type User struct {
	ID        int       `json:"id"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
	Email     string    `json:"email"`
	Role      string    `json:"role"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Vehicles  []Vehicle `json:"vehicles"`
}

type ListUser struct {
	ID              int           `json:"id"`
	FirstName       string        `json:"first_name"`
	LastName        string        `json:"last_name"`
	Email           string        `json:"email"`
	Role            string        `json:"role"`
	IsVerified      bool          `json:"is_verified"`
	IsPilotVerified bool          `json:"is_pilot_verified"`
	Files           []models.File `json:"files" gorm:"foreignkey:UserID"`
	CreatedAt       time.Time     `json:"created_at"`
	UpdatedAt       time.Time     `json:"updated_at"`
}
