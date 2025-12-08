package filter

type UserListFilter struct {
	Name string `form:"name"`

	ListFilter
}
