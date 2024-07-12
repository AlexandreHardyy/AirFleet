package repositories

import (
	"backend/models"
	"gorm.io/gorm"
)

type RatingRepositoryInterface interface {
	CreateRating(rating models.Rating) (models.Rating, error)
	UpdateRating(rating models.Rating) (models.Rating, error)
	GetRatingByID(ratingID int) (models.Rating, error)
	GetRatingsByUserID(userID int) ([]models.Rating, error)
	GetRatingsByPilotID(pilotID int) ([]models.Rating, error)
	GetRatingsByFlightID(flightID int) ([]models.Rating, error)
	GetRatingByUserIDAndStatus(userID int, status string) (models.Rating, error)
}

type RatingRepository struct {
	db *gorm.DB
}

func NewRatingRepository(db *gorm.DB) *RatingRepository {
	return &RatingRepository{db}
}

func (r *RatingRepository) CreateRating(rating models.Rating) (models.Rating, error) {
	err := r.db.Create(&rating).Error
	if err != nil {
		return rating, err
	}

	return rating, nil
}

func (r *RatingRepository) UpdateRating(rating models.Rating) (models.Rating, error) {
	err := r.db.Preload("Pilot").Save(&rating).Error
	if err != nil {
		return rating, err
	}

	return rating, nil
}

func (r *RatingRepository) GetRatingByID(ratingID int) (models.Rating, error) {
	var rating models.Rating
	err := r.db.Where("id = ?", ratingID).First(&rating).Error
	if err != nil {
		return rating, err
	}

	return rating, nil
}

func (r *RatingRepository) GetRatingsByUserID(userID int) ([]models.Rating, error) {
	var ratings []models.Rating
	query := r.db.Preload("Pilot").Where("user_id = ?", userID)
	err := query.Find(&ratings).Error

	if err != nil {
		return ratings, err
	}

	return ratings, nil
}

func (r *RatingRepository) GetRatingsByPilotID(pilotID int) ([]models.Rating, error) {
	var ratings []models.Rating
	query := r.db.Where("pilot_id = ?", pilotID)
	err := query.Find(&ratings).Error

	if err != nil {
		return ratings, err
	}

	return ratings, nil
}

func (r *RatingRepository) GetRatingsByFlightID(flightID int) ([]models.Rating, error) {
	var ratings []models.Rating
	query := r.db.Where("flight_id = ?", flightID)
	err := query.Find(&ratings).Error

	if err != nil {
		return ratings, err
	}

	return ratings, nil
}

func (r *RatingRepository) GetRatingByUserIDAndStatus(userID int, status string) (models.Rating, error) {
	var rating models.Rating
	query := r.db.Preload("Pilot").Where("user_id = ? AND status = ?", userID, status)
	err := query.First(&rating).Error

	if err != nil {
		return rating, err
	}

	return rating, nil
}
