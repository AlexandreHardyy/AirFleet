package models

import (
	"time"
)

type User struct {
	ID              int       `json:"id" gorm:"primaryKey;autoIncrement:true"`
	FirstName       string    `json:"first_name" gorm:"not null"`
	LastName        string    `json:"last_name" gorm:"not null"`
	Email           string    `json:"email" gorm:"unique;not null"`
	Password        string    `json:"password" gorm:"not null"`
	Role            string    `json:"role" gorm:"not null"`
	TokenVerify     string    `json:"token_verify"`
	IsVerified      bool      `json:"is_verified"`
	IsPilotVerified bool      `json:"is_pilot_verified"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
	Files           []File    `json:"files"`
	Vehicles        []Vehicle `json:"vehicles" gorm:"foreignkey:UserID"`
	Flights         []Flight  `json:"flights" gorm:"foreignkey:UserID"`
}
