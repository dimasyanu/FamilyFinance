package valueobjects

type UserId uint

func (id *UserId) ToUint() uint {
	return uint(*id)
}

func NewUserId(id uint) UserId {
	return UserId(id)
}
