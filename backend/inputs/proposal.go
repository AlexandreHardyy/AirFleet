package inputs

type InputCreateProposal struct {
	//DepartureTime  time.Time    `json:"departureTime" binding:"required"`
	Description    string       `json:"description" binding:"required"`
	AvailableSeats int          `json:"availableSeats" binding:"required"`
	CreateFlight   CreateFlight `json:"createFlight" binding:"required"`
	Price          float64      `json:"price" binding:"required"`
	VehicleID      int          `json:"vehicleId" binding:"required"`
}
