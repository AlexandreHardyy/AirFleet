package handlers

import (
	"backend/inputs"
	"backend/repositories"
	"backend/services"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"net/http"
)

type FlightHandler struct {
	flightService services.FlightServiceInterface
}

func GetFlightHandler(db *gorm.DB) *FlightHandler {
	flightRepository := repositories.NewFlightRepository(db)
	flightService := services.NewFlightService(flightRepository)
	return NewFlightHandler(flightService)
}

func NewFlightHandler(flightService services.FlightServiceInterface) *FlightHandler {
	return &FlightHandler{flightService}
}

func (h *FlightHandler) GetAll(c *gin.Context) {
	response := &Response{
		Message: "flight endpoint",
	}
	c.JSON(http.StatusOK, response)
}

func (h *FlightHandler) Create(c *gin.Context) {
	var input inputs.InputCreateFlight
	err := c.ShouldBindJSON(&input)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract JSON body",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	newFlight, err := h.flightService.CreateFlight(input)
	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	c.JSON(http.StatusCreated, newFlight)
}
