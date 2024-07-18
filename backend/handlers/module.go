package handlers

import (
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/responses"
	"backend/services"
	"errors"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"net/http"
	"strconv"
)

type ModuleHandler struct {
	moduleService services.ModuleServiceInterface
}

func GetModuleHandler(db *gorm.DB) *ModuleHandler {
	moduleRepository := repositories.NewModuleRepository(db)
	moduleService := services.NewModuleService(moduleRepository)
	return newModuleHandler(moduleService)
}

func newModuleHandler(moduleService services.ModuleServiceInterface) *ModuleHandler {
	return &ModuleHandler{moduleService}
}

// Update godoc
//
// @Summary Update module
// @Schemes
// @Description Update module
// @Tags modules
// @Accept			json
// @Produce		json
//
// @Param			id	path	int		true	"Module ID"
// @Param			is_enabled	body	bool	true	"Is Enabled"
//
// @Success		200				{object}	Response
// @Failure		400				{object}	Response
// @Failure		500				{object}	Response
//
// @Router			/modules/{id} [put]
//
// @Security	BearerAuth
func (h *ModuleHandler) Update(c *gin.Context) {
	moduleID := c.Param("id")
	convertedModuleID, err := strconv.Atoi(moduleID)
	if err != nil {
		c.JSON(400, gin.H{"error": "module id must be an integer"})
		return
	}

	module := inputs.InputUpdateModule{}
	err = c.ShouldBindJSON(&module)
	if err != nil {
		c.JSON(400, Response{
			Message: err.Error(),
		})
		return
	}

	response, err := h.moduleService.UpdateModule(convertedModuleID, module)
	if err != nil {
		c.JSON(500, Response{
			Message: err.Error(),
		})
		return
	}

	c.JSON(200, response)
}

// GetAllModules godoc
//
// @Summary Get all modules
// @Schemes
// @Description Get all modules
// @Tags modules
// @Accept			json
// @Produce		json
//
// @Param			limit	query	int		false	"Limit"
// @Param			offset	query	int		false	"Offset"
//
// @Success		200				{object}	[]responses.ResponseModule
// @Failure		400				{object}	Response
//
// @Router			/modules [get]
//
// @Security	BearerAuth
func (h *ModuleHandler) GetAllModules(c *gin.Context) {
	filters := make(map[string]interface{})
	queryParams := c.Request.URL.Query()
	for key, value := range queryParams {
		filters[key] = value[0]
	}

	modules, err := h.moduleService.GetAllModules(filters)
	if err != nil {
		c.JSON(500, Response{
			Message: err.Error(),
		})
		return
	}

	if len(modules) == 0 {
		c.JSON(http.StatusOK, []responses.ResponseModule{})
		return
	}

	c.JSON(200, modules)
}

// GetModuleByName godoc
//
// @Summary Get module by name
// @Schemes
// @Description Get module by name
// @Tags modules
// @Accept			json
// @Produce		json
//
// @Param			name	path	string	true	"Module Name"
//
// @Success		200				{object}	responses.ResponseModule
// @Failure		404				{object}	Response
// @Failure		500				{object}	Response
//
// @Router			/modules/{name} [get]
//
// @Security	BearerAuth
func (h *ModuleHandler) GetModuleByName(c *gin.Context) {
	moduleName := c.Param("name")
	filters := map[string]interface{}{"name": moduleName}

	module, err := h.moduleService.GetModule(filters)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, Response{
				Message: "module not found",
			})
		} else {
			repositories.CreateMonitoringLog(models.MonitoringLog{
				Type:    "error",
				Content: "[GetModule]: " + err.Error(),
			})

			c.JSON(http.StatusInternalServerError, Response{
				Message: err.Error(),
			})
		}
	}

	c.JSON(200, module)
}
