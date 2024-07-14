package models

type Module struct {
	ID        int    `json:"id" gorm:"primaryKey;autoIncrement:true"`
	Name      string `json:"name" gorm:"not null"`
	IsEnabled bool   `json:"is_enabled" gorm:"not null"`
}
