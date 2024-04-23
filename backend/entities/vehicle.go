package entities

import (
	"time"
)

type Vehicle struct {
	ID            int       `json:"id" gorm:"primaryKey;autoIncrement:true"`
	ModelName     string    `json:"model_name" gorm:"not null"`
	Matriculation string    `json:"matriculation" gorm:"not null"`
	Seat          int       `json:"seat" gorm:"not null"`
	Type          string    `json:"type" gorm:"not null"`
	IsVerified    bool      `json:"is_verified"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
	UserID        int       `json:"user_id"`
	User          User      `json:"user" gorm:"foreignkey:UserID"`
}
