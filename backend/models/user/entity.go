package user

import (
	"time"
)

type User struct {
	ID         int       `json:"id" gorm:"primaryKey;autoIncrement:true"`
	FirstName  string    `json:"first_name" gorm:"not null"`
	LastName   string    `json:"last_name" gorm:"not null"`
	Email      string    `json:"email" gorm:"unique;not null"`
	Password   string    `json:"password" gorm:"not null"`
	Role       string    `json:"role" gorm:"not null"`
	IsVerified bool      `json:"is_verified"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type UserFormatted struct {
	ID         int
	FirstName  string    `json:"first_name"`
	LastName   string    `json:"last_name"`
	Email      string    `json:"email"`
	Role       string    `json:"role"`
	IsVerified bool      `json:"is_verified"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}
