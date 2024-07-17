package handlers

import (
	"backend/data/roles"
	"backend/database"
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
	"backend/services"
	amazonS3 "backend/services/amazon-s3"
	"backend/services/brevo"
	"backend/utils"
	"backend/utils/token"
	"mime/multipart"
	"net/http"
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

// RegisterPilot godoc
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[Register]: " + err.Error(),
		})
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

		amazonS3.UploadToBucketS3(fileToUpload, newFileName)

		_, err := fileRepository.Create(models.File{
			Type:   fileType,
			Path:   newFileName,
			UserID: newUser.ID,
		})
		if err != nil {
			return
		}

	}

	repositories.CreateMonitoringLog(models.MonitoringLog{
		Type:    "info",
		Content: "[RegisterPilot]: " + input.Email,
	})

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
			Message: err.Error(),
		}
		c.JSON(http.StatusNotFound, response)
		return
	}

	repositories.CreateMonitoringLog(models.MonitoringLog{
		Type:    "info",
		Content: "[Login]: " + input.Email,
	})

	c.JSON(http.StatusOK, gin.H{
		"token": tkn,
	})
}

// ValidateAccount godoc
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
	tokenParam := c.Param("token")
	if tokenParam == "" {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Wrong token parameter",
		})
		return
	}

	err := th.userService.ValidateAccount(tokenParam)
	if err != nil {
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[ValidateAccount]: " + err.Error(),
		})
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Wrong token parameter",
		})
		return
	}

	repositories.CreateMonitoringLog(models.MonitoringLog{
		Type:    "info",
		Content: "[ValidateAccount]: account validated",
	})

	c.JSON(http.StatusOK, &Response{
		Message: "Email was verified successfully",
	})
}

// Update User godoc
//
// @Summary User
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

	var input inputs.UpdateUser
	err = c.ShouldBindJSON(&input)

	if err != nil {
		response := &Response{
			Message: "Cannot extract JSON body",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	user, err := th.userService.Update(id, input)
	if err != nil {
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[UpdateUser]: " + err.Error(),
		})
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Wrong id parameter",
		})
		return
	}

	c.JSON(http.StatusOK, user)
}

// ValidatePilotAccount godoc
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

	repositories.CreateMonitoringLog(models.MonitoringLog{
		Type:    "info",
		Content: "[ValidatePilotAccount]: " + user.Email,
	})

	brevo.SendEmailPilotAccountValidate(user.Email, user.FirstName)

	c.JSON(http.StatusOK, user)
}

// CurrentUser godoc
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[UserGetById]: " + err.Error(),
		})
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

func (th *UserHandler) GetUserFile(c *gin.Context) {
	fileType := c.Param("type")
	if fileType == "" {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Wrong type parameter",
		})
		return
	}
	userId, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Wrong id parameter",
		})
		return
	}

	userById, err := th.userService.GetById(userId)
	if err != nil {
		c.JSON(http.StatusNotFound, &Response{
			Message: "user not found",
		})
		return
	}

	for _, file := range userById.Files {
		if fileType == file.Type {
			myFile, err := amazonS3.DownloadFromBucketS3(file.Path)
			if err != nil {
				c.JSON(http.StatusNotFound, &Response{
					Message: err.Error(),
				})
				return
			}
			c.Data(http.StatusOK, "image/jpeg", myFile)
			break
		}
	}

	c.JSON(http.StatusNotFound, "")
}

func (th *UserHandler) UploadImage(c *gin.Context) {
	var input struct {
		Image *multipart.FileHeader `form:"image" binding:"required"`
	}
	if err := c.ShouldBind(&input); err != nil {
		c.JSON(http.StatusBadRequest, &Response{
			Message: err.Error(),
		})
		return
	}
	if !utils.IsImageValid(input.Image) {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Error: only file .jpeg .png .jpg are authorize with a size limit of 5mo",
		})
		return
	}

	userId, err := token.ExtractTokenID(c)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	user, err := th.userService.GetById(userId)
	if err != nil {
		c.JSON(http.StatusBadRequest, &Response{
			Message: err.Error(),
		})
		return
	}

	fileRepository := repositories.NewFileRepository(database.DB)

	extension := utils.GetFileExtension(input.Image.Filename)
	newFileName := utils.GenerateRandomString() + "." + extension

	amazonS3.UploadToBucketS3(input.Image, newFileName)

	_, err = fileRepository.Update(newFileName, user.ID)
	if err != nil {
		return
	}

	c.JSON(http.StatusNoContent, "")
}

// GetAll godoc
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
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[UserGetAll]: " + err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, users)
}

// Delete godoc
// @Summary Delete user
// @Schemes
// @Description delete a user
// @Tags user
// @Accept json
// @Produce json
//
//	@Param		id		path		int	true	"User ID"
//	@Success	204			{object}	nil
//	@Failure	400			{object}	Response
//
// @Router /users/{id} [delete]
func (th *UserHandler) Delete(c *gin.Context) {
	userId, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, &Response{
			Message: "Error: invalid user ID",
		})
		return
	}

	err = th.userService.Delete(userId)
	if err != nil {
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[UserDelete]: " + err.Error(),
		})
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	c.JSON(http.StatusNoContent, nil)
}
