package repositories

import (
	"backend/entities"
	"backend/responses"
	"backend/utils"
	"backend/utils/token"
	"errors"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type UserRepository interface {
	Create(user entities.User) (entities.User, error)
	Login(email string, password string) (string, error)
	GetUserById(id int) (entities.User, error)
	FindAllUsers() ([]responses.ResponseListUser, error)
}

type userRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *userRepository {
	return &userRepository{db}
}

func (r *userRepository) Create(user entities.User) (entities.User, error) {

	userErr := r.db.Where(&entities.User{Email: user.Email}).First(&user).Error
	if userErr == nil {
		return user, errors.New("email already used")
	}
	err := r.db.Create(&user).Error
	if err != nil {
		return user, err
	}
	return user, nil
}

func (r *userRepository) Login(email string, password string) (string, error) {
	user := entities.User{}
	err := r.db.Where(&entities.User{Email: email}).First(&user).Error
	if err != nil {
		return "", err
	}

	err = utils.VerifyPassword(password, user.Password)

	if err != nil && err == bcrypt.ErrMismatchedHashAndPassword {
		return "", err
	}

	token, _ := token.GenerateToken(user.ID)
	return token, nil
}

func (r *userRepository) GetUserById(id int) (entities.User, error) {
	user := entities.User{}
	err := r.db.Where(&entities.User{ID: id}).First(&user).Error
	if err != nil {
		return user, err
	}

	return user, nil
}

func (r *userRepository) FindAllUsers() ([]responses.ResponseListUser, error) {
	users := []responses.ResponseListUser{}
	err := r.db.Model(&entities.User{}).Find(&users).Error
	if err != nil {
		return users, err
	}

	return users, nil
}
