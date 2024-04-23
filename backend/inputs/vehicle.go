package inputs

type InputCreateVehicle struct {
	ModelName     string `json:"model_name" binding:"required"`
	Matriculation string `json:"matriculation" binding:"required"`
	Seat          int    `json:"seat" binding:"required"`
	Type          string `json:"type" binding:"required"`
	UserID        int    `json:"user_id" binding:"required"`
}

type InputUpdateVehicle struct {
	ModelName     string `json:"model_name"`
	Matriculation string `json:"matriculation"`
	Seat          int    `json:"seat"`
	Type          string `json:"type"`
	UserID        int    `json:"user_id"`
}
