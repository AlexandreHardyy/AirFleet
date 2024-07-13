package repositories

import (
	"backend/models"
	"gorm.io/gorm"
)

type RatingRepositoryInterface interface {
	CreateRating(rating models.Rating) (models.Rating, error)
	UpdateRating(rating models.Rating) (models.Rating, error)
	GetAllRatings(filters map[string]interface{}) ([]models.Rating, error)
	GetRatingByID(ratingID int) (models.Rating, error)
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

func (r *RatingRepository) GetAllRatings(filters map[string]interface{}) ([]models.Rating, error) {
	var ratings []models.Rating
	query := r.db

	for key, value := range filters {
		query = query.Where(key+" = ?", value)
	}

	err := query.Find(&ratings).Error
	if err != nil {
		return nil, err
	}

	return ratings, nil
}

func (r *RatingRepository) GetRatingByID(ratingID int) (models.Rating, error) {
	var rating models.Rating
	err := r.db.Where("id = ?", ratingID).First(&rating).Error
	if err != nil {
		return rating, err
	}

	return rating, nil
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
