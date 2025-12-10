package contracts

type IRequestHandler[TResult any] interface {
	Handle() (TResult, error)
}
