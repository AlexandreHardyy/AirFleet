package handlers

import (
	"backend/data/roles"
	"backend/database"
	"backend/models/file"
	"backend/models/user"
	"backend/utils"
	"backend/utils/token"
	"fmt"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"

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
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Error: cannot extract JSON body",
		})
		return
	}

	newUser, err := th.userService.Register(user.User{
		Email:     input.Email,
		LastName:  input.LastName,
		FirstName: input.FirstName,
		Password:  input.Password,
		Role:      roles.ROLE_USER,
	})
	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	c.JSON(http.StatusCreated, newUser)
}

// Register godoc
// @Summary Register pilot
// @Schemes
// @Description register for a pilot
// @Tags user
// @Accept multipart/form-data
// @Produce json
//
//	@Param		userInput	body		user.InputCreatePilot	true	"Message body"
//	@Success	201			{object}	user.ResponseUser
//	@Failure	400			{object}	Response
//
// @Router /users/pilot [post]
func (th *userHandler) RegisterPilot(c *gin.Context) {
	var input user.InputCreatePilot
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
	newUser, err := th.userService.Register(user.User{
		Email:     input.Email,
		FirstName: input.FirstName,
		LastName:  input.LastName,
		Password:  input.Password,
		Role:      roles.ROLE_PILOT,
	})

	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	fileRepository := file.NewRepository(database.DB)

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
		fileRepository.Create(file.File{
			Type:   fileType,
			Path:   filepath.Join("public", "files", fileType+"s", newFileName),
			UserID: newUser.ID,
		})

	}

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
