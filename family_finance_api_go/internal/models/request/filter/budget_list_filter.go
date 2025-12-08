package filter

type BudgetListFilter struct {
	DateFrom string `form:"date_from" binding:"omitempty,datetime=2006-01-02"`
	DateTo   string `form:"date_to" binding:"omitempty,datetime=2006-01-02"`
	Category uint   `form:"category" binding:"omitempty,gt=0"`
	ListFilter
}
