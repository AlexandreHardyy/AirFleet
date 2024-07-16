package handlers

import (
	"backend/inputs"
	"backend/repositories"
	"backend/responses"
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

// GetMyProposals godoc
//
// @Summary Get my proposals
// @Schemes
// @Description Get my proposals
// @Tags proposals
// @Accept			json
// @Produce		json
//
// @Success		200				{object}	[]responses.ResponseProposal
// @Failure		400				{object}	Response
//
// @Router			/proposals/me [get]
//
// @Security	BearerAuth
func (h *ProposalHandler) GetMyProposals(c *gin.Context) {
	userID, err := token.ExtractTokenID(c)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract user ID",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	proposals, err := h.proposalService.GetProposalsForMe(userID)
	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	if len(proposals) == 0 {
		c.JSON(http.StatusOK, []responses.ResponseProposal{})
		return
	}

	c.JSON(http.StatusOK, proposals)

}

// CreateProposal Create godoc
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
		println(err.Error())
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

// UpdateProposal godoc
//
// @Summary Update a proposal
// @Schemes
// @Description Update a proposal
// @Tags proposals
// @Accept			json
// @Produce		json
//
// @Param			id	path	int	true	"ID"
// @Param			proposal	body	inputs.InputUpdateProposal	true	"Proposal"
//
// @Success		200				{object}	responses.ResponseProposal
// @Failure		400				{object}	Response
//
// @Router			/proposals/{id} [patch]
//
// @Security	BearerAuth
func (h *ProposalHandler) UpdateProposal(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)

	if err != nil {
		c.String(http.StatusBadRequest, "Invalid ID format")
		return
	}

	var input inputs.InputUpdateProposal
	err = c.ShouldBindJSON(&input)
	if err != nil {
		response := &Response{
			Message: "Error: cannot extract JSON body",
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	updatedProposal, err := h.proposalService.UpdateProposal(id, input)
	if err != nil {
		response := &Response{
			Message: err.Error(),
		}
		c.JSON(http.StatusBadRequest, response)
		return
	}

	c.JSON(http.StatusOK, updatedProposal)
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

// JoinProposal godoc
//
// @Summary Join a proposal
// @Schemes
// @Description Join a proposal
// @Tags proposals
// @Accept			json
// @Produce		json
//
// @Param			id	path	int	true	"ID"
//
// @Success		200				{object}	Response
// @Failure		400				{object}	Response
//
// @Router			/proposals/{id}/join [patch]
//
// @Security	BearerAuth
func (h *ProposalHandler) JoinProposal(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)

	if err != nil {
		c.String(http.StatusBadRequest, "Invalid ID format")
		return
	}

	userID, err := token.ExtractTokenID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Error: cannot extract user ID"})
		return
	}

	err = h.proposalService.JoinProposal(id, userID)
	if err != nil {
		if err.Error() == "pilot cannot join their own flight" || err.Error() == "no available seats" {
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Proposal joined"})
}

// LeaveProposal godoc
//
// @Summary Leave a proposal
// @Schemes
// @Description Leave a proposal
// @Tags proposals
// @Accept			json
// @Produce		json
//
// @Param			id	path	int	true	"ID"
//
// @Success		200				{object}	Response
// @Failure		400				{object}	Response
//
// @Router			/proposals/{id}/leave [patch]
//
// @Security	BearerAuth
func (h *ProposalHandler) LeaveProposal(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)

	if err != nil {
		c.String(http.StatusBadRequest, "Invalid ID format")
		return
	}

	userID, err := token.ExtractTokenID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Error: cannot extract user ID"})
		return
	}

	err = h.proposalService.LeaveProposal(id, userID)
	if err != nil {
		if err.Error() == "user not found in flight" {
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Proposal left"})
}

// StartProposal startProposal godoc
//
// @Summary Start a proposal
// @Schemes
// @Description Start a proposal
// @Tags proposals
// @Accept			json
// @Produce		json
//
// @Param			id	path	int	true	"ID"
//
// @Success		200				{object}	Response
// @Failure		400				{object}	Response
//
// @Router			/proposals/{id}/start [patch]
//
// @Security	BearerAuth
func (h *ProposalHandler) StartProposal(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.String(http.StatusBadRequest, "Invalid ID format")
		return
	}

	userID, err := token.ExtractTokenID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Error: cannot extract user ID"})
		return
	}

	proposal, err := h.proposalService.StartProposal(id, userID)
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
