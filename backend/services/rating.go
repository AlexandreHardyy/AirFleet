package services

import (
	"backend/customErrors"
	"backend/inputs"
	"backend/repositories"
	"backend/responses"
	"net/http"
)

type RatingServiceInterface interface {
	UpdateRating(ratingID int, rating inputs.InputUpdateRating, userID int) (responses.ResponseRating, error)
	GetAllRatings(filters map[string]interface{}) ([]responses.ResponseRating, error)
	GetRatingsByPilotID(pilotID int, filters map[string]interface{}) ([]responses.ResponseRating, error)
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
		return responses.ResponseRating{}, &customErrors.CustomError{
			StatusCode: http.StatusForbidden,
			Message:    "you are not authorized to update this rating",
		}
	}

	if ratingModel.Status != "waiting_for_review" {
		return responses.ResponseRating{}, &customErrors.CustomError{
			StatusCode: http.StatusBadRequest,
			Message:    "rating has already been reviewed",
		}
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

func (s *RatingService) GetAllRatings(filters map[string]interface{}) ([]responses.ResponseRating, error) {
	ratingModels, err := s.repository.GetAllRatings(filters)
	if err != nil {
		return []responses.ResponseRating{}, err
	}

	var responseRatings []responses.ResponseRating
	for _, ratingModel := range ratingModels {
		responseRatings = append(responseRatings, responses.ResponseRating{
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
		})
	}

	return responseRatings, nil
}

func (s *RatingService) GetRatingsByPilotID(pilotID int, filters map[string]interface{}) ([]responses.ResponseRating, error) {
	ratingModels, err := s.repository.GetRatingsByPilotID(pilotID, filters)
	if err != nil {
		return []responses.ResponseRating{}, err
	}

	var responseRatings []responses.ResponseRating
	for _, ratingModel := range ratingModels {
		responseRatings = append(responseRatings, responses.ResponseRating{
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
		})
	}

	return responseRatings, nil
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
