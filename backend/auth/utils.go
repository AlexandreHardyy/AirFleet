package auth

import (
	"backend/data/roles"
	"backend/database"
	"backend/repositories"
)

func IsAdmin(userID int) (bool, error) {
	userRepository := repositories.NewUserRepository(database.DB)
	user, err := userRepository.GetById(userID)
	if err != nil {
		return false, err
	}
	return user.Role == roles.ROLE_ADMIN, nil
}
