package request

type SaveAccountRequest struct {
	UserID      uint    `json:"user_id" binding:"required"`
	Name        string  `json:"name" binding:"required"`
	Description string  `json:"description"`
	Color       string  `json:"color" binding:"required"`
	Balance     float64 `json:"balance"`
}
