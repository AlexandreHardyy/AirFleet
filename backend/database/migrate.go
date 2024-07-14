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
	)
	if err != nil {
		return
	}
}
