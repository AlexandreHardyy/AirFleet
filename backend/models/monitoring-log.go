package models

import (
	"time"
)

type MonitoringLog struct {
	ID        int       `json:"id" gorm:"primaryKey;autoIncrement:true"`
	Type      string    `json:"type" gorm:"not null"`
	Content   string    `json:"content" gorm:"not null"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
