package file

import (
	"time"
)

type File struct {
	ID        int       `json:"id" gorm:"primaryKey;autoIncrement:true"`
	Type      string    `json:"type" gorm:"not null"`
	Path      string    `json:"path" gorm:"not null"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	UserID    int       `json:"user_id"`
}
