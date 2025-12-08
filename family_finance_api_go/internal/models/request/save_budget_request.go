package request

type SaveBudgetRequest struct {
	Amount     float64 `json:"amount" binding:"required"`
	StartDate  string  `json:"start_date" binding:"required,datetime=2006-01-02"`
	EndDate    string  `json:"end_date" binding:"required,datetime=2006-01-02"`
	CategoryID uint    `json:"category_id" binding:"required"`
}
