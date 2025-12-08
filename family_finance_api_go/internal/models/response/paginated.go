package response

type Paginated[T any] struct {
	Items *[]T  `json:"items"`
	Total int64 `json:"total"`
}
