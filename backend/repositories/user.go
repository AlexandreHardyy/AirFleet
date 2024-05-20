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
	Login(email string, password string) (string, error)
	GetById(id int) (models.User, error)
	FindAll() ([]responses.ListUser, error)
	FindOne(models.User) (models.User, error)
	Update(user *models.User, userFields inputs.UpdateUser) error
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

func (r *userRepository) Login(email string, password string) (string, error) {
	user := models.User{}
	err := r.db.Where(&models.User{Email: email}).First(&user).Error
	if err != nil {
		return "", err
	}

	err = utils.VerifyPassword(password, user.Password)

	if err != nil && err == bcrypt.ErrMismatchedHashAndPassword {
		return "", errors.New("credentials errors")
	}

	if !user.IsVerified {
		return "", errors.New("account not validate")
	}

	if !user.IsPilotVerified && user.Role == roles.ROLE_PILOT {
		return "", errors.New("your pilot account is not validate yet")
	}

	token, _ := token.GenerateToken(user.ID)
	return token, nil
}

func (r *userRepository) GetById(id int) (models.User, error) {
	user := models.User{}
	err := r.db.Where(&models.User{ID: id}).First(&user).Error
	if err != nil {
		return user, err
	}

	return user, nil
}

func (r *userRepository) FindAll() ([]responses.ListUser, error) {
	users := []responses.ListUser{}
	err := r.db.Model(&models.User{}).Find(&users).Error
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
