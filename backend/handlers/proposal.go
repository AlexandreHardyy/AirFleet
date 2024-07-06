package handlers

import (
	"backend/inputs"
	"backend/repositories"
	"backend/services"
	"backend/utils/token"
	"errors"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"net/http"
	"strconv"
)

type ProposalHandler struct {
	proposalService services.ProposalServiceInterface
}

func GetProposalHandler(db *gorm.DB) *ProposalHandler {
	proposalRepository := repositories.NewProposalRepository(db)
	flightRepository := repositories.NewFlightRepository(db)
	proposalService := services.NewProposalService(proposalRepository, flightRepository)
	return NewProposalHandler(proposalService)
}

func NewProposalHandler(proposalService services.ProposalServiceInterface) *ProposalHandler {
	return &ProposalHandler{proposalService}
}

// GetAllProposal GetAll godoc
//
// @Summary Get all proposals
// @Schemes
// @Description Get all proposals
// @Tags proposals
// @Accept			json
// @Produce		json
//
// @Param			limit	query	int		false	"Limit"
// @Param			offset	query	int		false	"Offset"
//
// @Success		200				{object}	[]responses.ResponseProposal
// @Failure		400				{object}	Response
//
// @Router			/proposals [get]
//
// @Security	BearerAuth
func (h *ProposalHandler) GetAllProposal(c *gin.Context) {
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	proposals, err := h.proposalService.GetAllProposals(limit, offset)
	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	c.JSON(http.StatusOK, proposals)
}

// CreateProposal CreatePropsal Create godoc
//
// @Summary Create a proposal
// @Schemes
// @Description Create a proposal
// @Tags proposals
// @Accept			json
// @Produce		json
//
// @Param			proposal	body	inputs.InputCreateProposal	true	"Proposal"
//
// @Success		200				{object}	responses.ResponseProposal
// @Failure		400				{object}	Response
//
// @Router			/proposals [post]
//
// @Security	BearerAuth
func (h *ProposalHandler) CreateProposal(c *gin.Context) {
	var input inputs.InputCreateProposal
	err := c.ShouldBindJSON(&input)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract JSON body",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	userID, err := token.ExtractTokenID(c)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract user ID",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	newProposal, err := h.proposalService.CreateProposal(input, userID)
	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	c.JSON(http.StatusCreated, newProposal)
}

// GetProposal godoc
//
// @Summary Get a proposal
// @Schemes
// @Description Get a proposal
// @Tags proposals
// @Accept			json
// @Produce		json
//
// @Param			id	path	int	true	"ID"
//
// @Success		200				{object}	responses.ResponseProposal
// @Failure		400				{object}	Response
//
// @Router			/proposals/{id} [get]
//
// @Security	BearerAuth
func (h *ProposalHandler) GetProposal(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)

	if err != nil {
		c.String(http.StatusBadRequest, "Invalid ID format")
		return
	}

	proposal, err := h.proposalService.GetProposal(id)

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.Status(http.StatusNotFound)
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, proposal)
}

// DeleteProposal godoc
//
// @Summary Delete a proposal
// @Schemes
// @Description Delete a proposal
// @Tags proposals
// @Accept			json
// @Produce		json
//
// @Param			id	path	int	true	"ID"
//
// @Success		200				{object}	Response
// @Failure		400				{object}	Response
//
// @Router			/proposals/{id} [delete]
//
// @Security	BearerAuth
func (h *ProposalHandler) DeleteProposal(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)

	if err != nil {
		c.String(http.StatusBadRequest, "Invalid ID format")
		return
	}

	err = h.proposalService.DeleteProposal(id)

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.Status(http.StatusNotFound)
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Proposal deleted"})
}
