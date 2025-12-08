package response

type Creation[T any] struct {
	ID T `json:"id"`
}
