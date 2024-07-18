package services

import (
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
	"backend/utils"
	"errors"
)

type UserService interface {
	Register(user models.User) (responses.User, error)
	Login(input inputs.LoginUser) (string, error)
	ValidateAccount(token string) error
	GetById(id int) (models.User, error)
	GetAll() ([]responses.ListUser, error)
	Update(id int, userFields inputs.UpdateUser) (responses.User, error)
	Delete(id int) error
}

type userService struct {
	repository repositories.UserRepository
}

func NewUserService(r repositories.UserRepository) *userService {
	return &userService{r}
}

func (s *userService) Register(input models.User) (responses.User, error) {
	var user = input
	user.Password = utils.HashPassword(input.Password)
	user.IsVerified = false
	user.IsPilotVerified = false

	user, err := s.repository.Create(user)
	formattedUser := responses.User{
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

func (s *userService) Login(input inputs.LoginUser) (string, error) {

	token, err := s.repository.Login(input.Email, input.Password)
	if err != nil {
		return "", err
	}

	return token, nil
}

func (s *userService) ValidateAccount(token string) error {

	user, err := s.repository.FindOne(models.User{TokenVerify: token})
	if err != nil {
		return errors.New("wrong token email")
	}

	user.TokenVerify = ""
	user.IsVerified = true

	err = s.repository.Update(&user, inputs.UpdateUser{
		TokenVerify: "",
		IsVerified:  true,
	})

	return err
}

func (s *userService) GetById(id int) (models.User, error) {
	user, err := s.repository.GetById(id)
	if err != nil {
		return user, err
	}
	user.Password = ""
	return user, nil
}

func (s *userService) GetAll() ([]responses.ListUser, error) {
	users, err := s.repository.FindAll()
	if err != nil {
		return users, err
	}
	return users, nil
}

func (s *userService) Update(id int, userFields inputs.UpdateUser) (responses.User, error) {
	user, err := s.repository.GetById(id)
	if err != nil {
		return responses.User{}, err
	}

	err = s.repository.Update(&user, userFields)

	formattedUser := responses.User{
		ID:        user.ID,
		FirstName: user.FirstName,
		LastName:  user.LastName,
		Email:     user.Email,
		Role:      user.Role,
		CreatedAt: user.CreatedAt,
		UpdatedAt: user.UpdatedAt,
	}

	return formattedUser, err
}

func (s *userService) Delete(id int) error {
	user, err := s.repository.GetById(id)
	if err != nil {
		return err
	}

	err = s.repository.Delete(user)
	return err
}

func formatUsers(users []*models.User) []responses.ListUser {
	if len(users) == 0 {
		return []responses.ListUser{}
	}
	var responseUsers []responses.ListUser
	for _, user := range users {
		responseUsers = append(responseUsers, responses.ListUser{
			ID:         user.ID,
			FirstName:  user.FirstName,
			LastName:   user.LastName,
			Email:      user.Email,
			Role:       user.Role,
			IsVerified: user.IsVerified,
			CreatedAt:  user.CreatedAt,
			UpdatedAt:  user.UpdatedAt,
		})
	}
	return responseUsers
}
