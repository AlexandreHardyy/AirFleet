package user

import (
	"backend/utils"
	"backend/utils/token"
	"errors"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type Repository interface {
	Create(user User) (User, error)
	Login(email string, password string) (string, error)
	GetById(id int) (User, error)
	FindAll() ([]ResponseListUser, error)
}

type repository struct {
	db *gorm.DB
}

func NewRepository(db *gorm.DB) *repository {
	return &repository{db}
}

func (r *repository) Create(user User) (User, error) {

	userErr := r.db.Where(&User{Email: user.Email}).First(&user).Error
	if userErr == nil {
		return user, errors.New("email already used")
	}
	err := r.db.Create(&user).Error
	if err != nil {
		return user, err
	}
	return user, nil
}

func (r *repository) Login(email string, password string) (string, error) {
	user := User{}
	err := r.db.Where(&User{Email: email}).First(&user).Error
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

func (r *repository) GetById(id int) (User, error) {
	user := User{}
	err := r.db.Where(&User{ID: id}).First(&user).Error
	if err != nil {
		return user, err
	}

	return user, nil
}

func (r *repository) FindAll() ([]ResponseListUser, error) {
	users := []ResponseListUser{}
	err := r.db.Model(&User{}).Find(&users).Error
	if err != nil {
		return users, err
	}

	return users, nil
}
