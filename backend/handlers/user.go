package handlers

import (
	"backend/models/user"
	"backend/utils/token"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type userHandler struct {
	userService user.Service
}

func GetUser(db *gorm.DB) (userHandler *userHandler) {
	userRepository := user.NewRepository(db)
	userService := user.NewService(userRepository)
	userHandler = NewUserHandler(userService)
	return userHandler
}

func NewUserHandler(userService user.Service) *userHandler {
	return &userHandler{userService}
}

func (th *userHandler) Register(c *gin.Context) {
	var input user.InputCreateUser
	err := c.ShouldBindJSON(&input)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract JSON body",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	newUser, err := th.userService.Register(input)
	if err != nil {
		response := &Response{
			Message: "Error: Something went wrong",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	c.JSON(http.StatusCreated, newUser)
}

func (th *userHandler) Login(c *gin.Context) {
	var input user.InputLoginUser
	err := c.ShouldBindJSON(&input)
	if err != nil {
		response := &Response{
			Message: "Cannot extract JSON body",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	tkn, err := th.userService.Login(input)
	if err != nil {
		response := &Response{
			Message: "Invalid credentials",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": tkn,
	})
}

func (th *userHandler) CurrentUser(c *gin.Context) {

	userId, err := token.ExtractTokenID(c)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := th.userService.GetById(userId)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"email": user.Email,
	})
}

func (th *userHandler) GetAll(c *gin.Context) {

	users, err := th.userService.GetAll()

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, users)
}
