package models

import "time"

type Rating struct {
	ID        int       `json:"id" gorm:"primaryKey;autoIncrement:true"`
	Rating    float64   `json:"rating" gorm:"not null"`
	Comment   string    `json:"comment"`
	Status    string    `json:"status" gorm:"not null"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	UserID    int       `json:"user_id" gorm:"not null"`
	User      User      `json:"user" gorm:"foreignkey:UserID"`
	PilotID   int       `json:"pilot_id" gorm:"not null"`
	Pilot     User      `json:"pilot" gorm:"foreignkey:PilotID"`
	FlightID  int       `json:"flight_id" gorm:"not null"`
	Flight    Flight    `json:"flight" gorm:"foreignkey:FlightID"`
}
