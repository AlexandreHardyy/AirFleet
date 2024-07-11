package services

import (
	"backend/inputs"
	"backend/repositories"
	"backend/responses"
	"errors"
)

type RatingServiceInterface interface {
	UpdateRating(ratingID int, rating inputs.InputUpdateRating, userID int) (responses.ResponseRating, error)
	GetRatingByUserIDAndStatus(userID int, status string) (responses.ResponseRating, error)
}

type RatingService struct {
	repository repositories.RatingRepositoryInterface
}

func NewRatingService(repository repositories.RatingRepositoryInterface) *RatingService {
	return &RatingService{repository}
}

func (s *RatingService) UpdateRating(ratingID int, rating inputs.InputUpdateRating, userID int) (responses.ResponseRating, error) {
	ratingModel, err := s.repository.GetRatingByID(ratingID)
	if err != nil {
		return responses.ResponseRating{}, err
	}

	if ratingModel.UserID != userID {
		return responses.ResponseRating{}, errors.New("you are not authorized to update this rating")
	}

	if ratingModel.Status != "waiting_for_review" {
		return responses.ResponseRating{}, errors.New("you are not authorized to update this rating")
	}

	if rating.Rating != nil && rating.Comment != nil {
		ratingModel.Rating = *rating.Rating
		ratingModel.Comment = *rating.Comment
		ratingModel.Status = "reviewed"
	} else {
		ratingModel.Status = "rejected"
	}

	ratingModel, err = s.repository.UpdateRating(ratingModel)
	if err != nil {
		return responses.ResponseRating{}, err
	}

	return responses.ResponseRating{
		ID:      ratingModel.ID,
		Rating:  ratingModel.Rating,
		Comment: ratingModel.Comment,
		Status:  ratingModel.Status,
		PilotID: ratingModel.PilotID,
		Pilot: responses.ListUser{
			ID:         ratingModel.Pilot.ID,
			FirstName:  ratingModel.Pilot.FirstName,
			LastName:   ratingModel.Pilot.LastName,
			Email:      ratingModel.Pilot.Email,
			Role:       ratingModel.Pilot.Role,
			IsVerified: ratingModel.Pilot.IsVerified,
			CreatedAt:  ratingModel.Pilot.CreatedAt,
			UpdatedAt:  ratingModel.Pilot.UpdatedAt,
		},
		CreatedAt: ratingModel.CreatedAt,
		UpdatedAt: ratingModel.UpdatedAt,
	}, nil
}

func (s *RatingService) GetRatingByUserIDAndStatus(userID int, status string) (responses.ResponseRating, error) {
	ratingModel, err := s.repository.GetRatingByUserIDAndStatus(userID, status)
	if err != nil {
		return responses.ResponseRating{}, err
	}

	return responses.ResponseRating{
		ID:      ratingModel.ID,
		Rating:  ratingModel.Rating,
		Comment: ratingModel.Comment,
		Status:  ratingModel.Status,
		PilotID: ratingModel.PilotID,
		Pilot: responses.ListUser{
			ID:         ratingModel.Pilot.ID,
			FirstName:  ratingModel.Pilot.FirstName,
			LastName:   ratingModel.Pilot.LastName,
			Email:      ratingModel.Pilot.Email,
			Role:       ratingModel.Pilot.Role,
			IsVerified: ratingModel.Pilot.IsVerified,
			CreatedAt:  ratingModel.Pilot.CreatedAt,
			UpdatedAt:  ratingModel.Pilot.UpdatedAt,
		},
		CreatedAt: ratingModel.CreatedAt,
		UpdatedAt: ratingModel.UpdatedAt,
	}, nil
}
