package tools

import (
	"reflect"

	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
)

type Mediator struct {
	handlers map[reflect.Type]contracts.IRequestHandler[contracts.IRequest[IMediatorResult], IMediatorResult]
}

type IMediatorResult any

func (m *Mediator) Send(command contracts.IRequest[IMediatorResult]) (IMediatorResult, error) {
	handlerType := reflect.TypeOf(command)
	handler, exists := m.handlers[handlerType]
	if exists {
		return handler.Handle(command)
	}
	return nil, nil
}

func NewMediator(handlers map[reflect.Type]contracts.IRequestHandler[contracts.IRequest[IMediatorResult], IMediatorResult]) *Mediator {
	return &Mediator{
		handlers: handlers,
	}
}
