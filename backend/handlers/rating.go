package handlers

import (
	"backend/inputs"
	"backend/models"
	"backend/repositories"
	"backend/services"
	"backend/utils/token"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type RatingHandler struct {
	ratingService services.RatingServiceInterface
}

func GetRatingHandler(db *gorm.DB) *RatingHandler {
	ratingRepository := repositories.NewRatingRepository(db)
	ratingService := services.NewRatingService(ratingRepository)
	return newRatingHandler(ratingService)
}

func newRatingHandler(ratingService services.RatingServiceInterface) *RatingHandler {
	return &RatingHandler{ratingService}
}

// Update godoc
//
// @Summary Update rating
// @Schemes
// @Description Update rating
// @Tags ratings
// @Accept			json
// @Produce		json
//
// @Param			id	path	int		true	"Rating ID"
// @Param			rating	body	object	false	"Rating"
// @Param			comment	body	object	false	"Comment"
//
// @Success		200				{object}	Response
// @Failure		400				{object}	Response
// @Failure		500				{object}	Response
//
// @Router			/ratings/{id} [put]
//
// @Security	BearerAuth
func (h *RatingHandler) Update(c *gin.Context) {
	ratingID := c.Param("id")
	convertedRatingID, err := strconv.Atoi(ratingID)
	if err != nil {
		c.JSON(400, gin.H{"error": "rating id must be an integer"})
		return
	}

	rating := inputs.InputUpdateRating{}
	err = c.ShouldBindJSON(&rating)
	if err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	userID, err := token.ExtractTokenID(c)
	if err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	response, err := h.ratingService.UpdateRating(convertedRatingID, rating, userID)
	if err != nil {
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[UpdateRating]: " + err.Error(),
		})
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, response)
}

// GetAllRatings godoc
//
// @Summary Get all ratings
// @Schemes
// @Description Get all ratings
// @Tags ratings
// @Accept			json
// @Produce		json
//
// @Param			status	query	string	false	"Status"
//
// @Success		200				{object}	[]responses.ResponseRating
// @Failure		400				{object}	Response
//
// @Router			/ratings [get]
//
// @Security	BearerAuth
func (h *RatingHandler) GetAllRatings(c *gin.Context) {
	filters := make(map[string]interface{})
	queryParams := c.Request.URL.Query()
	for key, values := range queryParams {
		if len(values) > 0 {
			filters[key] = values[0]
		}
	}

	userID, err := token.ExtractTokenID(c)
	if err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	filters["pilot_id"] = userID

	response, err := h.ratingService.GetAllRatings(filters)
	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, response)

}

// GetRatingByUserIDAndStatus godoc
//
// @Summary Get rating by user ID and status
// @Schemes
// @Description Get rating by user ID and status
// @Tags ratings
// @Accept			json
// @Produce		json
//
// @Param			status	path	string	true	"Status"
//
// @Success		200				{object}	[]responses.ResponseRating
// @Failure		400				{object}	Response
//
// @Router			/ratings/status/{status} [get]
//
// @Security	BearerAuth
func (h *RatingHandler) GetRatingByUserIDAndStatus(c *gin.Context) {
	userID, err := token.ExtractTokenID(c)
	if err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	status := c.Param("status")

	response, err := h.ratingService.GetRatingByUserIDAndStatus(userID, status)
	if err != nil {
		repositories.CreateMonitoringLog(models.MonitoringLog{
			Type:    "error",
			Content: "[GetRatingByUserIDAndStatus]: " + err.Error(),
		})
		response := &Response{
			Message: err.Error(),
		}

		//TODO status can be different
		c.JSON(http.StatusNotFound, response)
		return
	}

	c.JSON(200, response)
}
