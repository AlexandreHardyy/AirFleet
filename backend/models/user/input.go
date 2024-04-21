package user

import "mime/multipart"

type InputCreateUser struct {
	Email     string `json:"email" binding:"required,email"`
	FirstName string `json:"first_name" binding:"required"`
	LastName  string `json:"last_name" binding:"required"`
	Password  string `json:"password" binding:"required"`
}

type InputCreatePilot struct {
	Email          string                `form:"email" binding:"required,email"`
	FirstName      string                `form:"first_name" binding:"required"`
	LastName       string                `form:"last_name" binding:"required"`
	Password       string                `form:"password" binding:"required"`
	IdCard         *multipart.FileHeader `form:"id_card" binding:"required"`
	DrivingLicence *multipart.FileHeader `form:"driving_licence" binding:"required"`
}

type InputLoginUser struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}
