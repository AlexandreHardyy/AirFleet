package database

import (
	"backend/models/file"
	"backend/models/user"
)

func Migrate() {
	DB.AutoMigrate(&user.User{}, &file.File{})
}
