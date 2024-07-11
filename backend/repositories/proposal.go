package repositories

import (
	"backend/inputs"
	"backend/models"
	"gorm.io/gorm"
)

type ProposalRepositoryInterface interface {
	GetAllProposals(limit int, offset int) ([]models.Proposal, error)
	GetProposalByID(proposalID int) (models.Proposal, error)
	CreateProposal(proposal models.Proposal) (models.Proposal, error)
	UpdateProposal(proposal *models.Proposal, proposalFields inputs.InputUpdateProposal) error
	DeleteProposal(proposal models.Proposal) error
}

type ProposalRepository struct {
	db *gorm.DB
}

func NewProposalRepository(db *gorm.DB) *ProposalRepository {
	return &ProposalRepository{db}
}

func (r *ProposalRepository) GetAllProposals(limit int, offset int) ([]models.Proposal, error) {
	var proposals []models.Proposal
	query := r.db.Preload("Flight").
		Preload("Flight.Users").
		Preload("Flight.Pilot").
		Preload("Flight.Vehicle").
		Offset(offset).
		Limit(limit)

	err := query.Find(&proposals).Error
	if err != nil {
		return proposals, err
	}
	return proposals, nil
}

func (r *ProposalRepository) GetProposalByID(proposalID int) (models.Proposal, error) {
	var proposal models.Proposal
	err := r.db.Preload("Flight").
		Preload("Flight.Users").
		Preload("Flight.Pilot").
		Preload("Flight.Vehicle").
		Where("id = ?", proposalID).First(&proposal).Error
	if err != nil {
		return proposal, err
	}
	return proposal, nil
}

func (r *ProposalRepository) CreateProposal(proposal models.Proposal) (models.Proposal, error) {
	err := r.db.Create(&proposal).Error
	if err != nil {
		return proposal, err
	}
	return proposal, nil
}

func (r *ProposalRepository) UpdateProposal(proposal *models.Proposal, proposalFields inputs.InputUpdateProposal) error {
	err := r.db.Model(&proposal).Updates(proposalFields).Error
	if err != nil {
		return err
	}

	return nil
}

func (r *ProposalRepository) DeleteProposal(proposal models.Proposal) error {
	result := r.db.Delete(&proposal)
	if result.Error != nil {
		return result.Error
	}

	return nil
}
