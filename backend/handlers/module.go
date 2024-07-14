package handlers

import (
	"backend/inputs"
	"backend/repositories"
	"backend/responses"
	"backend/services"
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

func (h *ModuleHandler) GetModuleByName(c *gin.Context) {
	moduleName := c.Param("name")
	filters := map[string]interface{}{"name": moduleName}

	module, err := h.moduleService.GetModule(filters)
	if err != nil {
		c.JSON(500, Response{
			Message: err.Error(),
		})
		return
	}

	c.JSON(200, module)
}
