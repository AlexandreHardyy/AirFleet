package responses

type ResponseModule struct {
	ID        int    `json:"id"`
	Name      string `json:"name"`
	IsEnabled bool   `json:"is_enabled"`
}
