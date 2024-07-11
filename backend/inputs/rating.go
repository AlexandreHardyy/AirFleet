package inputs

type InputUpdateRating struct {
	Rating  *float64 `json:"rating"`
	Comment *string  `json:"comment"`
}
