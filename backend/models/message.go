package models

import (
	"time"
)

type Message struct {
	ID        int       `json:"id" gorm:"primaryKey;autoIncrement:true"`
	Content   string    `json:"content" gorm:"not null"`
	CreatedAt time.Time `json:"created_at"`
	UserID    int       `json:"user_id"`
	User      User      `json:"user" gorm:"foreignkey:UserID"`
	FlightID  int       `json:"flight_id"`
	Flight    Flight    `json:"flight" gorm:"foreignkey:FlightID"`
}
