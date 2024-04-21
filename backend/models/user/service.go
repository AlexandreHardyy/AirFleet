package user

import (
	"backend/utils"
	"errors"
)

type Service interface {
	Register(user User) (ResponseUser, error)
	Login(input InputLoginUser) (string, error)
	GetById(id int) (User, error)
	GetAll() ([]ResponseListUser, error)
}

type service struct {
	repository Repository
}

func NewService(r Repository) *service {
	return &service{r}
}

func (s *service) Register(input User) (ResponseUser, error) {
	var user User = input
	user.Password = utils.HashPassword(input.Password)
	user.IsVerified = false
	user.IsPilotVerified = false

	user, err := s.repository.Create(user)
	formattedUser := ResponseUser{
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

func (s *service) Login(input InputLoginUser) (string, error) {

	token, err := s.repository.Login(input.Email, input.Password)
	if err != nil {
		return "", errors.New("credentials invalid")
	}

	return token, nil
}

func (s *service) GetById(id int) (User, error) {
	user, err := s.repository.GetById(id)
	if err != nil {
		return user, err
	}
	user.Password = ""
	return user, nil
}

func (s *service) GetAll() ([]ResponseListUser, error) {
	users, err := s.repository.FindAll()
	if err != nil {
		return users, err
	}
	return users, nil
}
