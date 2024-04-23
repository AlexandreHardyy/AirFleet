package database

import (
	"backend/models"
)

func Migrate() {
	DB.AutoMigrate(&models.User{}, &models.File{}, &models.Vehicle{})
}
