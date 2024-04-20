package user

import (
	"backend/data/roles"
	"backend/utils"
	"errors"
)

type Service interface {
	Register(user InputCreateUser) (ResponseUser, error)
	Login(input InputLoginUser) (string, error)
	GetById(id int) (User, error)
	GetAll() ([]ResponseListUser, error)
	Update(id int, user InputUpdateUser) (ResponseUser, error) // new method
	Delete(id int) error                                       // new method
}

type service struct {
	repository Repository
}

func NewService(r Repository) *service {
	return &service{r}
}

func (s *service) Register(input InputCreateUser) (ResponseUser, error) {
	var user User = User{
		FirstName: input.FirstName,
		LastName:  input.LastName,
		Email:     input.Email,
		Password:  utils.HashPassword(input.Password),
		Role:      roles.ROLE_USER,
	}

	user, err := s.repository.Register(user)
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

func (s *service) Update(id int, input InputUpdateUser) (ResponseUser, error) {
	user := User{
		FirstName: input.FirstName,
		LastName:  input.LastName,
		Email:     input.Email,
		Password:  utils.HashPassword(input.Password),
		Role:      input.Role,
	}
	user, err := s.repository.Update(id, user)
	if err != nil {
		return ResponseUser{}, err
	}
	return ResponseUser{
		ID:        user.ID,
		FirstName: user.FirstName,
		LastName:  user.LastName,
		Email:     user.Email,
		Role:      user.Role,
		CreatedAt: user.CreatedAt,
		UpdatedAt: user.UpdatedAt,
	}, nil
}

func (s *service) Delete(id int) error {
	return s.repository.Delete(id)
}
