package response

type Creation[T any] struct {
	Id T `json:"id"`
}
