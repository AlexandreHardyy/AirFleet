package responses

type ResponseMessage struct {
	ID        int      `json:"id"  binding:"required"`
	Content   string   `json:"content"  binding:"required"`
	UserID    int      `json:"user_id"`
	FlightID  int      `json:"flight_id"`
	CreatedAt string   `json:"created_at"`
	User      ListUser `json:"user"`
}
