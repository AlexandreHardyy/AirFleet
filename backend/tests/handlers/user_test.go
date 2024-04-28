package handlers_test

import (
	"backend/inputs"
	"backend/models"
	"backend/responses"
	"backend/services"
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"

	"backend/handlers"
)

type MockUserRepository struct {
	mock.Mock
}

func (m *MockUserRepository) Create(input models.User) (models.User, error) {
	args := m.Called(input)
	return args.Get(0).(models.User), args.Error(1)
}

func (m *MockUserRepository) Login(email string, password string) (string, error) {
	args := m.Called(email, password)
	return args.String(0), args.Error(1)
}

func (m *MockUserRepository) GetById(id int) (models.User, error) {
	args := m.Called(id)
	return args.Get(0).(models.User), args.Error(1)
}

func (m *MockUserRepository) FindAll() ([]responses.ListUser, error) {
	args := m.Called()
	return args.Get(0).([]responses.ListUser), args.Error(1)
}

func (m *MockUserRepository) FindOne(user models.User) (models.User, error) {
	args := m.Called(user)
	return args.Get(0).(models.User), args.Error(1)
}

func (m *MockUserRepository) Update(user *models.User, userFields inputs.UpdateUser) error {
	args := m.Called(user, userFields)
	return args.Error(0)
}

func (m *MockUserRepository) Delete(user models.User) error {
	args := m.Called(user)
	return args.Error(0)
}

func TestRegisterCreatedSuccessfully(t *testing.T) {
	t.Log("Register: user inputs should be created successfully")
	mockUserRepository := new(MockUserRepository)
	userService := services.NewUserService(mockUserRepository)
	handler := handlers.NewUserHandler(userService)

	input := inputs.CreateUser{
		Email:     "quoi@feur.com",
		FirstName: "quoi",
		LastName:  "feur",
		Password:  "password123",
	}

	mockUser := models.User{
		ID:        1,
		Email:     "quoi@feur.com",
		FirstName: "quoi",
		LastName:  "feur",
		Password:  "password123",
		Role:      "ROLE_USER",
		UpdatedAt: time.Date(1, time.January, 1, 0, 0, 0, 0, time.UTC),
		CreatedAt: time.Date(1, time.January, 1, 0, 0, 0, 0, time.UTC),
	}
	mockUserRepository.On("Register", mock.AnythingOfType("user.User")).Return(mockUser, nil)

	// Prepare HTTP request
	jsonInput, _ := json.Marshal(input)
	req, _ := http.NewRequest("POST", "/users", bytes.NewBuffer(jsonInput))
	w := httptest.NewRecorder()
	gin.SetMode("release")
	c, _ := gin.CreateTestContext(w)
	c.Request = req

	handler.Register(c)

	assert.Equal(t, http.StatusCreated, w.Code)

	var responseUser responses.User
	err := json.Unmarshal(w.Body.Bytes(), &responseUser)
	assert.NoError(t, err)
	assert.Equal(t, responses.User{
		ID:        1,
		Email:     "quoi@feur.com",
		FirstName: "quoi",
		LastName:  "feur",
		Role:      "ROLE_USER",
		UpdatedAt: time.Date(1, time.January, 1, 0, 0, 0, 0, time.UTC),
		CreatedAt: time.Date(1, time.January, 1, 0, 0, 0, 0, time.UTC),
	}, responseUser)

	mockUserRepository.AssertExpectations(t)
}

func TestRegisterWrongArguments(t *testing.T) {
	t.Log("Register: user inputs should be created successfully")
	mockUserRepository := new(MockUserRepository)
	userService := services.NewUserService(mockUserRepository)
	handler := handlers.NewUserHandler(userService)

	input := inputs.CreateUser{
		Email:    "quoi@feur.com",
		Password: "password123",
	}

	// Prepare HTTP request
	jsonInput, _ := json.Marshal(input)
	req, _ := http.NewRequest("POST", "/users", bytes.NewBuffer(jsonInput))
	w := httptest.NewRecorder()
	gin.SetMode("release")
	c, _ := gin.CreateTestContext(w)
	c.Request = req

	// Execute the handler
	handler.Register(c)

	// Verify the responses
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestUpdateUser(t *testing.T) {
	t.Log("Update: user input should be updated successfully")
	mockUserRepository := new(MockUserRepository)
	userService := services.NewUserService(mockUserRepository)
	handler := handlers.NewUserHandler(userService)

	input := models.User{
		Email:     "updated@feur.com",
		FirstName: "updated",
		LastName:  "feur",
		Password:  "password123",
		Role:      "ROLE_USER",
	}

	mockUser := models.User{
		ID:        1,
		Email:     "updated@feur.com",
		FirstName: "updated",
		LastName:  "feur",
		Password:  "password123",
		Role:      "ROLE_USER",
		UpdatedAt: time.Date(1, time.January, 1, 0, 0, 0, 0, time.UTC),
		CreatedAt: time.Date(1, time.January, 1, 0, 0, 0, 0, time.UTC),
	}
	mockUserRepository.On("Update", 1, mock.AnythingOfType("user.User")).Return(mockUser, nil)

	// Prepare HTTP request
	jsonInput, _ := json.Marshal(input)
	req, _ := http.NewRequest("PUT", "/users/1", bytes.NewBuffer(jsonInput))
	w := httptest.NewRecorder()
	gin.SetMode("release")
	c, _ := gin.CreateTestContext(w)
	c.Request = req

	handler.Update(c)

	assert.Equal(t, http.StatusOK, w.Code)

	var responseUser models.User
	err := json.Unmarshal(w.Body.Bytes(), &responseUser)
	assert.NoError(t, err)
	assert.Equal(t, models.User{
		ID:        1,
		Email:     "updated@feur.com",
		FirstName: "updated",
		LastName:  "feur",
		Role:      "ROLE_USER",
		UpdatedAt: time.Date(1, time.January, 1, 0, 0, 0, 0, time.UTC),
		CreatedAt: time.Date(1, time.January, 1, 0, 0, 0, 0, time.UTC),
	}, responseUser)

	mockUserRepository.AssertExpectations(t)
}

func TestDeleteUser(t *testing.T) {
	t.Log("Delete: user should be deleted successfully")
	mockUserRepository := new(MockUserRepository)
	userService := services.NewUserService(mockUserRepository)
	handler := handlers.NewUserHandler(userService)

	mockUserRepository.On("Delete", 1).Return(nil)

	// Prepare HTTP request
	req, _ := http.NewRequest("DELETE", "/users/1", nil)
	w := httptest.NewRecorder()
	gin.SetMode("release")
	c, _ := gin.CreateTestContext(w)
	c.Request = req

	handler.Delete(c)

	assert.Equal(t, http.StatusNoContent, w.Code)

	mockUserRepository.AssertExpectations(t)
}
