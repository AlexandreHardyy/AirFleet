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
		&models.Proposal{},
		&models.Rating{},
		&models.MonitoringLog{},
		&models.Module{},
		&models.Payment{},
	)
	if err != nil {
		return
	}
}
