package inputs

type Airport struct {
	Name      string  `json:"name"`
	Address   string  `json:"address"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type InputCreateFlight struct {
	Departure Airport `json:"departure" binding:"required"`
	Arrival   Airport `json:"arrival" binding:"required"`
}
