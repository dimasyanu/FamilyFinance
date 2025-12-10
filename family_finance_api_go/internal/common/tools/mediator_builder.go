package tools

import (
	"reflect"

	"github.com/dimasyanu/family-finance-go/internal/common/constants"
	"github.com/dimasyanu/family-finance-go/internal/common/contracts"
)

type MediatorBuilder struct {
	handlers map[reflect.Type]contracts.IRequestHandler[any]
	services *map[constants.ServiceKeys]any
}

func (b *MediatorBuilder) Register(handlers ...contracts.IRequestHandler[any]) {
	if b.handlers == nil {
		b.handlers = make(map[reflect.Type]contracts.IRequestHandler[any])
	}
	for _, handler := range handlers {
		handlerType := reflect.TypeOf(handler).Elem().Field(0).Type
		b.handlers[handlerType] = handler
	}
}

func (b *MediatorBuilder) UseServiceProviders(services *map[constants.ServiceKeys]any) {
	b.services = services
}

func (b *MediatorBuilder) Build() *Mediator {
	return &Mediator{
		services: b.services,
		handlers: b.handlers,
	}
}
