package filter

type ListFilter struct {
	Limit  int `form:"limit"`
	Offset int `form:"offset"`
}
