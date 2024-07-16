package models

import (
	"time"
)

type Proposal struct {
	ID             int       `json:"id" gorm:"primaryKey;autoIncrement:true"`
	DepartureTime  time.Time `json:"departure_time" gorm:"not null"`
	Description    string    `json:"description" gorm:"not null"`
	AvailableSeats int       `json:"available_seats" gorm:"not null"`
	FlightID       int       `json:"flight_id" gorm:"not null"`
	Flight         Flight    `json:"flight" gorm:"foreignkey:FlightID"`
}
