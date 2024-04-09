package handlers_test

import (
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
	"backend/models/user"
)

type MockUserService struct {
	mock.Mock
}

func (m *MockUserService) Register(input user.InputCreateUser) (user.User, error) {
	args := m.Called(input)
	return args.Get(0).(user.User), args.Error(1)
}

func (m *MockUserService) Login(input user.InputLoginUser) (string, error) {
	args := m.Called(input)
	return args.String(0), args.Error(1)
}

func (m *MockUserService) GetById(id int) (user.User, error) {
	args := m.Called(id)
	return args.Get(0).(user.User), args.Error(1)
}

func (m *MockUserService) GetAll() ([]user.InputListUser, error) {
	args := m.Called()
	return args.Get(0).([]user.InputListUser), args.Error(1)
}

func TestRegisterCreatedSuccessfully(t *testing.T) {
	t.Log("Register: user input should be created successfully")
	mockUserService := new(MockUserService)
	handler := handlers.NewUserHandler(mockUserService)

	// Prepare test data
	input := user.InputCreateUser{
		Email:     "quoi@feur.com",
		FirstName: "quoi",
		LastName:  "feur",
		Password:  "password123",
	}

	// Mock behavior
	mockUser := user.User{
		ID:        1,
		Email:     "quoi@feur.com",
		FirstName: "quoi",
		LastName:  "feur",
		Password:  "password123",
		Role:      "ROLE_USER",
		UpdatedAt: time.Date(1, time.January, 1, 0, 0, 0, 0, time.UTC),
		CreatedAt: time.Date(1, time.January, 1, 0, 0, 0, 0, time.UTC),
	}
	mockUserService.On("Register", input).Return(mockUser, nil)

	// Prepare HTTP request
	jsonInput, _ := json.Marshal(input)
	req, _ := http.NewRequest("POST", "/users", bytes.NewBuffer(jsonInput))
	w := httptest.NewRecorder()
	gin.SetMode("release")
	c, _ := gin.CreateTestContext(w)
	c.Request = req

	// Execute the handler
	handler.Register(c)

	// Verify the response
	assert.Equal(t, http.StatusCreated, w.Code)

	var responseUser user.User
	err := json.Unmarshal(w.Body.Bytes(), &responseUser)
	assert.NoError(t, err)
	assert.Equal(t, mockUser, responseUser)
	println("ROLE", mockUser.Role, "ROLE2", responseUser.Role)

	mockUserService.AssertExpectations(t)
}

func TestRegisterWrongInput(t *testing.T) {
	t.Log("Register: user input should be wrong")
	mockUserService := new(MockUserService)
	handler := handlers.NewUserHandler(mockUserService)

	// Prepare test data
	input := user.InputCreateUser{
		Email:     "quoi@feur.com",
		FirstName: "quoi",
	}

	mockUserService.On("Register", input).Return(user.User{}, nil)

	// Prepare HTTP request
	jsonInput, _ := json.Marshal(input)
	req, _ := http.NewRequest("POST", "/users", bytes.NewBuffer(jsonInput))
	w := httptest.NewRecorder()
	gin.SetMode("release")
	c, _ := gin.CreateTestContext(w)
	c.Request = req

	// Execute the handler
	handler.Register(c)

	// Verify the response
	assert.Equal(t, http.StatusBadRequest, w.Code)

}
