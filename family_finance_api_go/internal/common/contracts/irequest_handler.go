package contracts

import "context"

type IRequestHandler[TResult any] interface {
	Init(ctx context.Context) error
	Handle() (*TResult, error)
}
