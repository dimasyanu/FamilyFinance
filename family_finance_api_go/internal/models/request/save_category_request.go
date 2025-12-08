package request

type SaveCategoryRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	Icon        int    `json:"icon" binding:"required"`
	Color       string `json:"color" binding:"required"`
	UserId      uint   `json:"user_id" default:"0"`
}
