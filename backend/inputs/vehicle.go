package inputs

type CreateVehicle struct {
	ModelName      string  `json:"model_name" binding:"required"`
	Matriculation  string  `json:"matriculation" binding:"required"`
	Seat           int     `json:"seat" binding:"required"`
	Type           string  `json:"type" binding:"required"`
	CruiseSpeed    float64 `json:"cruise_speed" binding:"required"`
	CruiseAltitude float64 `json:"cruise_altitude" binding:"required"`
	IsVerified     bool    `json:"is_verified"`
}

type UpdateVehicle struct {
	ModelName      string  `json:"model_name"`
	Matriculation  string  `json:"matriculation"`
	Seat           int     `json:"seat"`
	Type           string  `json:"type"`
	CruiseSpeed    float64 `json:"cruise_speed"`
	CruiseAltitude float64 `json:"cruise_altitude"`
	UserID         int     `json:"user_id"`
	IsVerified     bool    `json:"is_verified"`
	IsSelected     *bool   `json:"is_selected"`
}
