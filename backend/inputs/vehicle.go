package inputs

type CreateVehicle struct {
	ModelName     string `json:"model_name" binding:"required"`
	Matriculation string `json:"matriculation" binding:"required"`
	Seat          int    `json:"seat" binding:"required"`
	Type          string `json:"type" binding:"required"`
}

type UpdateVehicle struct {
	ModelName     string `json:"model_name"`
	Matriculation string `json:"matriculation"`
	Seat          int    `json:"seat"`
	Type          string `json:"type"`
	UserID        int    `json:"user_id"`
}
