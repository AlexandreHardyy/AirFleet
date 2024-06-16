package middlewares

import (
	"backend/data/roles"
	"backend/database"
	"backend/repositories"
	"backend/utils/token"
	"net/http"

	"github.com/gin-gonic/gin"
)

func IsAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		println("middleware auth")
		err := token.TokenValid(c)
		if err != nil {
			c.Status(http.StatusUnauthorized)
			c.Abort()
			return
		}
		c.Next()
	}
}

func IsPilotAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		println("middleware pilot auth")
		err := token.TokenValid(c)
		if err != nil {
			c.Status(http.StatusUnauthorized)
			c.Abort()
			return
		}
		userId, _ := token.ExtractTokenID(c)
		userRepository := repositories.NewUserRepository(database.DB)

		currentUser, err := userRepository.GetById(userId)
		if err != nil || currentUser.Role != roles.ROLE_PILOT {
			c.Status(http.StatusForbidden)
			c.Abort()
			return
		}
		c.Next()
	}
}

func IsAdminAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		println("middleware admin auth")
		err := token.TokenValid(c)
		if err != nil {
			c.Status(http.StatusUnauthorized)
			c.Abort()
			return
		}
		userId, _ := token.ExtractTokenID(c)
		userRepository := repositories.NewUserRepository(database.DB)

		currentUser, err := userRepository.GetById(userId)
		if err != nil || currentUser.Role != roles.ROLE_ADMIN {
			c.Status(http.StatusForbidden)
			c.Abort()
			return
		}
		c.Next()
	}
}
