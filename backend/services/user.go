package services

import (
	"backend/entities"
	"backend/inputs"
	"backend/repositories"
	"backend/responses"
	"backend/utils"
	"errors"
)

type UserService interface {
	Register(user entities.User) (responses.ResponseUser, error)
	Login(input inputs.InputLoginUser) (string, error)
	GetById(id int) (entities.User, error)
	GetAll() ([]responses.ResponseListUser, error)
}

type userService struct {
	repository repositories.UserRepository
}

func NewUserService(r repositories.UserRepository) *userService {
	return &userService{r}
}

func (s *userService) Register(input entities.User) (responses.ResponseUser, error) {
	var user entities.User = input
	user.Password = utils.HashPassword(input.Password)
	user.IsVerified = false
	user.IsPilotVerified = false

	user, err := s.repository.Create(user)
	formattedUser := responses.ResponseUser{
		ID:        user.ID,
		FirstName: user.FirstName,
		LastName:  user.LastName,
		Email:     user.Email,
		Role:      user.Role,
		CreatedAt: user.CreatedAt,
		UpdatedAt: user.UpdatedAt,
	}
	if err != nil {
		return formattedUser, err
	}

	return formattedUser, nil
}

func (s *userService) Login(input inputs.InputLoginUser) (string, error) {

	token, err := s.repository.Login(input.Email, input.Password)
	if err != nil {
		return "", errors.New("credentials invalid")
	}

	return token, nil
}

func (s *userService) GetById(id int) (entities.User, error) {
	user, err := s.repository.GetUserById(id)
	if err != nil {
		return user, err
	}
	user.Password = ""
	return user, nil
}

func (s *userService) GetAll() ([]responses.ResponseListUser, error) {
	users, err := s.repository.FindAllUsers()
	if err != nil {
		return users, err
	}
	return users, nil
}
