package handlers

import (
	"backend/inputs"
	"backend/repositories"
	"backend/services"
	"errors"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"net/http"
	"strconv"
)

type vehicleHandler struct {
	vehicleService services.VehicleService
}

func GetVehicle(db *gorm.DB) (vehicleHandler *vehicleHandler) {
	vehicleRepository := repositories.NewVehicleRepository(db)
	vehicleService := services.NewVehicleService(vehicleRepository)
	vehicleHandler = NewVehicleHandler(vehicleService)
	return vehicleHandler
}

func NewVehicleHandler(vehicleService services.VehicleService) *vehicleHandler {
	return &vehicleHandler{vehicleService}
}

// CreateVehicle Register godoc
//
//	@Summary	Create vehicle
//	@Schemes
//	@Description	create a new vehicle for a pilot
//	@Tags			vehicle
//	@Accept			json
//	@Produce		json
//
//	@Param			vehicleInput	body		inputs.InputCreateVehicle	true	"Message body"
//	@Success		201				{object}	responses.ResponseVehicle
//	@Failure		400				{object}	Response
//
//	@Router			/vehicles [post]
func (th *vehicleHandler) CreateVehicle(c *gin.Context) {
	var input inputs.InputCreateVehicle
	err := c.ShouldBindJSON(&input)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract JSON body",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	newVehicle, err := th.vehicleService.CreateVehicle(input)
	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	c.JSON(http.StatusCreated, newVehicle)
}

// GetAll Get all godoc
//
//	@Summary	Get all vehicles
//	@Schemes
//	@Description	get all vehicles
//	@Tags			vehicle
//	@Accept			json
//	@Produce		json
//
//	@Success		200	{object}	[]responses.ResponseVehicle
//	@Failure		401	{object}	Response
//
//	@Router			/vehicles [get]
//
//	@Security	BearerAuth
func (th *vehicleHandler) GetAll(c *gin.Context) {

	vehicles, err := th.vehicleService.GetAll()

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, vehicles)
}

// VehcileById vehicle godoc
//
// @Summary get vehicle by id
// @Schemes
// @Description get vehicle by id
// @Tags vehicle
// @Accept json
// @Produce json
// @Param id path int true "Vehicle ID"
//
//	@Success	200			{object}	responses.ResponseVehicle
//	@Failure	404			{object}	Response
//
// @Router /vehicles/{id} [get]
func (th *vehicleHandler) VehcileById(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)

	if err != nil {
		c.String(http.StatusBadRequest, "Invalid ID format")
		return
	}

	vehicles, err := th.vehicleService.GetById(id)

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.Status(http.StatusNotFound)
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, vehicles)
}

// DeleteVehicle godoc
//
// @Summary delete vehicle by id
// @Schemes
// @Description delete vehicle by id
// @Tags vehicle
// @Accept json
// @Produce json
// @Param id path int true "Vehicle ID"
//
//	@Success	200			{object}	Response
//	@Failure	404			{object}	Response
//
// @Router /vehicles/{id} [delete]
func (th *vehicleHandler) DeleteVehicle(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)

	if err != nil {
		c.String(http.StatusBadRequest, "Invalid ID format")
		return
	}

	err = th.vehicleService.Delete(id)

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.Status(http.StatusNotFound)
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Vehicle deleted"})
}

// UpdateVehicle godoc
//
// @Summary update vehicle by id
// @Schemes
// @Description update vehicle by id
// @Tags vehicle
// @Accept json
// @Produce json
// @Param id path int true "Vehicle ID"
// @Param vehicleInput body inputs.InputUpdateVehicle true "Message body"
//
//	@Success	200			{object}	responses.ResponseVehicle
//	@Failure	404			{object}	Response
//
// @Router /vehicles/{id} [patch]
func (th *vehicleHandler) UpdateVehicle(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)

	if err != nil {
		c.String(http.StatusBadRequest, "Invalid ID format")
		return
	}

	var input inputs.InputUpdateVehicle
	err = c.ShouldBindJSON(&input)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract JSON body",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	vehicle, err := th.vehicleService.Update(id, input)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.Status(http.StatusNotFound)
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, vehicle)
}
