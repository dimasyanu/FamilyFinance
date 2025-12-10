package tools

import (
	"reflect"

	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
)

type Mediator struct {
	services *map[constants.ServiceKeys]any
	handlers map[reflect.Type]contracts.IRequestHandler[any]
}

type IMediatorResult any

func (m *Mediator) Send(request contracts.IRequestHandler[any]) (IMediatorResult, error) {
	handlerType := reflect.TypeOf(request)
	handler, exists := m.handlers[handlerType]
	if exists {
		return handler.Handle()
	}
	return nil, nil
}

func NewMediator(builderFunc func(b *MediatorBuilder)) *Mediator {
	builder := &MediatorBuilder{}
	builderFunc(builder)
	return builder.Build()
}
