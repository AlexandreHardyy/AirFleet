package database

import (
	"backend/entities"
)

func Migrate() {
	DB.AutoMigrate(&entities.User{}, &entities.File{}, &entities.Vehicle{})
}
