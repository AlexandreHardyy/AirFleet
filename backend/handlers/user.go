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

// Register godoc
// @Summary Register user
// @Schemes
// @Description register for a normal client
// @Tags user
// @Accept json
// @Produce json
//
//	@Param		userInput	body		user.InputCreateUser	true	"Message body"
//	@Success	201			{object}	user.ResponseUser
//	@Failure	400			{object}	Response
//
// @Router /users [post]
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
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	c.JSON(http.StatusCreated, newUser)
}

// Login godoc
// @Summary Register example
// @Schemes
// @Description register for a client
// @Tags user
// @Accept json
// @Produce json
//
//	@Param		userInput	body		user.InputLoginUser	true	"Message body"
//	@Success	200			{object}	user.ResponseLogin
//	@Failure	404			{object}	Response
//
// @Router /users/login [post]
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
		c.JSON(http.StatusNotFound, response)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": tkn,
	})
}

// Current godoc
//
// @Summary Current user
// @Schemes
// @Description get current user
// @Tags user
// @Accept json
// @Produce json
//
//	@Success	200			{object}	user.ResponseUser
//	@Failure	401         {object}	Response
//
// @Router /users/me [get]
//
//	@Security	BearerAuth
func (th *userHandler) CurrentUser(c *gin.Context) {

	userId, err := token.ExtractTokenID(c)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userById, err := th.userService.GetById(userId)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, user.ResponseUser{
		ID:        userById.ID,
		Email:     userById.Email,
		FirstName: userById.FirstName,
		LastName:  userById.LastName,
		Role:      userById.Role,
		CreatedAt: userById.CreatedAt,
		UpdatedAt: userById.UpdatedAt,
	})
}

// Get all godoc
//
// @Summary Get all users
// @Schemes
// @Description get all user for admins
// @Tags user
// @Accept json
// @Produce json
//
//	@Success	200			{object}	[]user.ResponseListUser
//	@Failure	401         {object}	Response
//
// @Router /users [get]
//
//	@Security	BearerAuth
func (th *userHandler) GetAll(c *gin.Context) {

	users, err := th.userService.GetAll()

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, users)
}
