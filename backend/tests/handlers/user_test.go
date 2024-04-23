package handlers_test

import (
	"backend/entities"
	"backend/inputs"
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

func (m *MockUserRepository) Create(input entities.User) (entities.User, error) {
	args := m.Called(input)
	return args.Get(0).(entities.User), args.Error(1)
}

func (m *MockUserRepository) Login(email string, password string) (string, error) {
	args := m.Called(email, password)
	return args.String(0), args.Error(1)
}

func (m *MockUserRepository) GetUserById(id int) (entities.User, error) {
	args := m.Called(id)
	return args.Get(0).(entities.User), args.Error(1)
}

func (m *MockUserRepository) FindAllUsers() ([]responses.ResponseListUser, error) {
	args := m.Called()
	return args.Get(0).([]responses.ResponseListUser), args.Error(1)
}

func TestRegisterCreatedSuccessfully(t *testing.T) {
	t.Log("Register: user inputs should be created successfully")
	mockUserRepository := new(MockUserRepository)
	userService := services.NewUserService(mockUserRepository)
	handler := handlers.NewUserHandler(userService)

	input := inputs.InputCreateUser{
		Email:     "quoi@feur.com",
		FirstName: "quoi",
		LastName:  "feur",
		Password:  "password123",
	}

	mockUser := entities.User{
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

	var responseUser responses.ResponseUser
	err := json.Unmarshal(w.Body.Bytes(), &responseUser)
	assert.NoError(t, err)
	assert.Equal(t, responses.ResponseUser{
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

	input := inputs.InputCreateUser{
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
