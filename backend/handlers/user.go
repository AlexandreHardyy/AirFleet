package handlers

import (
	"backend/data/roles"
	"backend/database"
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
	"backend/services"
	"backend/services/brevo"
	"backend/utils"
	"backend/utils/token"
	"fmt"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type UserHandler struct {
	userService services.UserService
}

func GetUser(db *gorm.DB) (userHandler *UserHandler) {
	userRepository := repositories.NewUserRepository(db)
	userService := services.NewUserService(userRepository)
	userHandler = NewUserHandler(userService)
	return userHandler
}

func NewUserHandler(userService services.UserService) *UserHandler {
	return &UserHandler{userService}
}

// Register godoc
// @Summary Register user
// @Schemes
// @Description register for a normal client
// @Tags user
// @Accept json
// @Produce json
//
//	@Param		userInput	body		inputs.CreateUser	true	"Message body"
//	@Success	201			{object}	responses.User
//	@Failure	400			{object}	Response
//
// @Router /users [post]
func (th *UserHandler) Register(c *gin.Context) {
	var input inputs.CreateUser
	err := c.ShouldBindJSON(&input)
	if err != nil {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Error: cannot extract JSON body",
		})
		return
	}

	tokenVerify := utils.GenerateRandomString()
	newUser, err := th.userService.Register(models.User{
		Email:       input.Email,
		LastName:    input.LastName,
		FirstName:   input.FirstName,
		Password:    input.Password,
		Role:        roles.ROLE_USER,
		TokenVerify: tokenVerify,
	})
	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	brevo.SendEmailToVerify(newUser.Email, newUser.FirstName+" "+newUser.LastName, tokenVerify)

	c.JSON(http.StatusCreated, newUser)
}

// RegisterPilot Register godoc
// @Summary Register pilot
// @Schemes
// @Description register for a pilot
// @Tags user
// @Accept multipart/form-data
// @Produce json
//
//	@Param		userInput	body		inputs.CreatePilot	true	"Message body"
//	@Success	201			{object}	responses.User
//	@Failure	400			{object}	Response
//
// @Router /users/pilot [post]
func (th *UserHandler) RegisterPilot(c *gin.Context) {
	var input inputs.CreatePilot
	if err := c.ShouldBind(&input); err != nil {
		println(err.Error())
		c.JSON(http.StatusBadRequest, &Response{
			Message: err.Error(),
		})
		return
	}
	if !utils.IsFileValid(input.DrivingLicence) || !utils.IsFileValid(input.IdCard) {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Error: only file .jpeg .png .jpg .pdf are authorize with a size limit of 5mo",
		})
		return
	}

	dir, _ := os.Getwd()
	tokenVerify := utils.GenerateRandomString()
	newUser, err := th.userService.Register(models.User{
		Email:       input.Email,
		FirstName:   input.FirstName,
		LastName:    input.LastName,
		Password:    input.Password,
		Role:        roles.ROLE_PILOT,
		TokenVerify: tokenVerify,
	})

	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	fileRepository := repositories.NewFileRepository(database.DB)

	for fileType, fileToUpload := range map[string]*multipart.FileHeader{
		"id-card":         input.IdCard,
		"driving-licence": input.DrivingLicence,
	} {
		extension := utils.GetFileExtension(fileToUpload.Filename)
		newFileName := utils.GenerateRandomString() + "." + extension
		if err := c.SaveUploadedFile(fileToUpload, filepath.Join(dir, "public", "files", fileType+"s", newFileName)); err != nil {
			c.JSON(http.StatusInternalServerError, &Response{Message: fmt.Sprintf("%s upload failed", fileType)})
			return
		}
		fileRepository.Create(models.File{
			Type:   fileType,
			Path:   filepath.Join("public", "files", fileType+"s", newFileName),
			UserID: newUser.ID,
		})

	}

	brevo.SendEmailToVerify(newUser.Email, newUser.FirstName+" "+newUser.LastName, tokenVerify)

	c.JSON(http.StatusCreated, newUser)
}

// Login godoc
// @Summary Login
// @Schemes
// @Description login a client
// @Tags user
// @Accept json
// @Produce json
//
//	@Param		userInput	body		inputs.LoginUser	true	"Message body"
//	@Success	200			{object}	responses.Login
//	@Failure	400			{object}	Response
//
// @Router /users/login [post]
func (th *UserHandler) Login(c *gin.Context) {
	var input inputs.LoginUser
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

// Validate Account godoc
//
// @Summary Validate Account
// @Schemes
// @Description validate account with token
// @Tags user
//
//	@Param		token	path		string	true	"Token"
//
// @Produce json
//
//	@Success	200			{object}	Response
//	@Success	400			{object}	Response
//
// @Router /users/validate/{token} [get]
func (th *UserHandler) ValidateAccount(c *gin.Context) {
	token := c.Param("token")
	if token == "" {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Wrong token parameter",
		})
		return
	}

	err := th.userService.ValidateAccount(token)
	if err != nil {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Wrong token parameter",
		})
		return
	}

	c.JSON(http.StatusOK, &Response{
		Message: "Email was verified successfully",
	})
}

// Update User godoc
//
// @Summary User User
// @Schemes
// @Description Update user
// @Tags user
// @Produce json
// @Accept  json
//
//	@Param		id	path		string	true	"ID"
//	@Param		userInput	body		inputs.UpdateUser	true	"Body..."
//
//
//	@Success	200			{object}	responses.User
//	@Success	400			{object}	Response
//
// @Router /users/{id} [patch]
//
//	@Security	BearerAuth
func (th *UserHandler) Update(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Wrong id parameter",
		})
		return
	}

	println(id)

	var input inputs.UpdateUser
	err = c.ShouldBindJSON(&input)

	if err != nil {
		response := &Response{
			Message: "Cannot extract JSON body",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}
	println(input.Email)

	user, err := th.userService.Update(id, input)
	if err != nil {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Wrong id parameter",
		})
		return
	}

	c.JSON(http.StatusOK, user)
}

// Validate Pilot Account godoc
//
// @Summary Validate Pilot Account
// @Schemes
// @Description Update user
// @Tags user
// @Produce json
//
//	@Param		id	path		string	true	"ID"
//
//	@Success	200			{object}	responses.User
//	@Success	400			{object}	Response
//	@Success	404			{object}	Response
//
// @Router /users/pilot-validate/{id} [patch]
//
//	@Security	BearerAuth
func (th *UserHandler) ValidatePilotAccount(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Wrong id parameter",
		})
		return
	}

	user, err := th.userService.Update(id, inputs.UpdateUser{IsPilotVerified: true})
	if err != nil {
		c.JSON(http.StatusNotFound, &Response{
			Message: "User not found",
		})
		return
	}

	brevo.SendEmailPilotAccountValidate(user.Email, user.FirstName)

	c.JSON(http.StatusOK, user)
}

// CurrentUser Current godoc
//
// @Summary Current user
// @Schemes
// @Description get current user
// @Tags user
// @Accept json
// @Produce json
//
//	@Success	200			{object}	responses.User
//	@Failure	401         {object}	Response
//
// @Router /users/me [get]
//
//	@Security	BearerAuth
func (th *UserHandler) CurrentUser(c *gin.Context) {

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

	c.JSON(http.StatusOK, responses.User{
		ID:        userById.ID,
		Email:     userById.Email,
		FirstName: userById.FirstName,
		LastName:  userById.LastName,
		Role:      userById.Role,
		CreatedAt: userById.CreatedAt,
		UpdatedAt: userById.UpdatedAt,
	})
}

// GetAll Get all godoc
//
// @Summary Get all users
// @Schemes
// @Description get all user for admins
// @Tags user
// @Accept json
// @Produce json
//
//	@Success	200			{object}	[]responses.ListUser
//	@Failure	401         {object}	Response
//
// @Router /users [get]
//
//	@Security	BearerAuth
func (th *UserHandler) GetAll(c *gin.Context) {

	users, err := th.userService.GetAll()

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, users)
}
