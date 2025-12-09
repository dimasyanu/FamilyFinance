package contracts

type IRequestHandler[TRequest IRequest[IMediatorResult], IMediatorResult any] interface {
	Handle(request TRequest) (IMediatorResult, error)
}
