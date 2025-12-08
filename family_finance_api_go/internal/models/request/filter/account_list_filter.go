package filter

type AccountListFilter struct {
	Search string `form:"search"`

	ListFilter
}
