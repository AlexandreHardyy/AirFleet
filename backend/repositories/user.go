package repositories

import (
	"backend/data/roles"
	"backend/inputs"
	"backend/models"
	"backend/responses"
	"backend/utils"
	"backend/utils/token"
	"errors"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type UserRepository interface {
	Create(user models.User) (models.User, error)
	Login(email string, password string) (models.UserLoginResponse, error)
	GetById(id int) (models.User, error)
	FindAll() ([]responses.ListUser, error)
	FindOne(user models.User) (models.User, error)
	Update(user *models.User, userFields inputs.UpdateUser) error
	Delete(user models.User) error
}

type userRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *userRepository {
	return &userRepository{db}
}

func (r *userRepository) Create(user models.User) (models.User, error) {

	userErr := r.db.Where(&models.User{Email: user.Email}).First(&user).Error
	if userErr == nil {
		return user, errors.New("email already used")
	}
	err := r.db.Create(&user).Error
	if err != nil {
		return user, err
	}
	return user, nil
}

func (r *userRepository) Login(email string, password string) (models.UserLoginResponse, error) {
	user := models.User{}
	err := r.db.Where(&models.User{Email: email}).First(&user).Error
	if err != nil {
		return models.UserLoginResponse{}, errors.New("credentials customErrors")
	}

	err = utils.VerifyPassword(password, user.Password)

	if err != nil && err == bcrypt.ErrMismatchedHashAndPassword {
		return models.UserLoginResponse{}, errors.New("credentials customErrors")
	}

	if !user.IsVerified {
		return models.UserLoginResponse{}, errors.New("your account is not validate yet")
	}

	if !user.IsPilotVerified && user.Role == roles.ROLE_PILOT {
		return models.UserLoginResponse{}, errors.New("your pilot account is not validate yet")
	}
	tkn, _ := token.GenerateToken(user.ID)

	return models.UserLoginResponse{Token: tkn, Role: user.Role}, nil
}

func (r *userRepository) GetById(id int) (models.User, error) {
	user := models.User{}
	err := r.db.Preload("Vehicles").Preload("Files").Where(&models.User{ID: id}).First(&user).Error
	if err != nil {
		return user, err
	}

	return user, nil
}

func (r *userRepository) FindAll() ([]responses.ListUser, error) {
	var users []responses.ListUser
	err := r.db.Preload("Files").Model(&models.User{}).Find(&users).Error
	if err != nil {
		return users, err
	}

	return users, nil
}

func (r *userRepository) FindOne(userFilter models.User) (models.User, error) {
	user := models.User{}
	err := r.db.Where(&userFilter).First(&user).Error
	if err != nil {
		return user, err
	}

	return user, nil
}

func (r *userRepository) Update(user *models.User, userFields inputs.UpdateUser) error {
	err := r.db.Model(&user).Updates(userFields).Error
	if err != nil {
		return err
	}

	return nil
}
func (r *userRepository) Delete(user models.User) error {
	result := r.db.Delete(&user)
	if result.Error != nil {
		return result.Error
	}

	return nil
}
