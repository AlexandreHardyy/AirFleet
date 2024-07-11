package database

import (
	"backend/models"
)

func Migrate() {
	err := DB.AutoMigrate(
		&models.User{},
		&models.File{},
		&models.Vehicle{},
		&models.Flight{},
		&models.Message{},
		&models.Rating{},
	)
	if err != nil {
		return
	}
}
