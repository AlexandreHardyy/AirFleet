package user

import (
	"backend/utils"
	"errors"
)

type Service interface {
	Register(user InputCreateUser) (User, error)
	Login(input InputLoginUser) (string, error)
	GetById(id int) (User, error)
	GetAll() ([]InputListUser, error)
}

type service struct {
	repository Repository
}

func NewService(r Repository) *service {
	return &service{r}
}

func (s *service) Register(input InputCreateUser) (User, error) {
	var user User
	user.Email = input.Email
	user.Password = utils.HashPassword(input.Password)

	user, err := s.repository.Register(user)
	if err != nil {
		return user, err
	}

	return user, nil
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

func (s *service) GetAll() ([]InputListUser, error) {
	users, err := s.repository.FindAll()
	if err != nil {
		return users, err
	}
	return users, nil
}
