package models

import "time"

type Flight struct {
	ID                 int       `json:"id" gorm:"primaryKey;autoIncrement:true"`
	Status             string    `json:"status" gorm:"not null"`
	DepartureName      string    `json:"departure_name" gorm:"not null"`
	DepartureAddress   string    `json:"departure_address" gorm:"not null"`
	DepartureLatitude  float64   `json:"departure_latitude" gorm:"not null"`
	DepartureLongitude float64   `json:"departure_longitude" gorm:"not null"`
	ArrivalName        string    `json:"arrival_name" gorm:"not null"`
	ArrivalAddress     string    `json:"arrival_address" gorm:"not null"`
	ArrivalLatitude    float64   `json:"arrival_latitude" gorm:"not null"`
	ArrivalLongitude   float64   `json:"arrival_longitude" gorm:"not null"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
	Price              *float64  `json:"price"`
	Users              []*User   `json:"user" gorm:"many2many:flight_users;"`
	PilotID            *int      `json:"pilot_id"`
	Pilot              User      `json:"pilot" gorm:"foreignkey:PilotID"`
	VehicleID          *int      `json:"vehicle_id"`
	Vehicle            Vehicle   `json:"vehicle" gorm:"foreignkey:VehicleID"`
}
