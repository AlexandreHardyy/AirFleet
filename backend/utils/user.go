package utils

import "backend/models"

func ContainsUser(users []*models.User, userID int) bool {
	for _, user := range users {
		if user.ID == userID {
			return true
		}
	}
	return false
}

func NotContainsUser(users []*models.User, userID int) bool {
	for _, user := range users {
		if user.ID == userID {
			return false
		}
	}
	return true
}
