package request

type SaveTransactionRequest struct {
	TransactionType int     `json:"transaction_type" binding:"required,oneof=-1 0 1"` // -1 for expense, 1 for income, 0 for transfer
	Amount          float64 `json:"amount" binding:"required,gt=0"`
	Date            string  `json:"date" binding:"required,datetime=2006-01-02"`
	Description     string  `json:"description" binding:"max=500"`
	CategoryID      uint    `json:"category_id" binding:"omitempty,gt=0"`
	AccountID       uint    `json:"account_id" binding:"required,gt=0"`
	TargetAccountID uint    `json:"target_account_id" binding:"omitempty,gt=0"` // for transfer transactions
}
