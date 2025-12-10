package models

import "time"

type Timestamp struct {
	CreatedAt time.Time `gorm:"column:created_at;autoCreateTime" json:"created_at"`
	CreatedBy string    `gorm:"column:created_by;type:varchar(100);not null" json:"created_by"`
	UpdatedBy string    `gorm:"column:updated_by;type:varchar(100);not null" json:"updated_by"`
	UpdatedAt time.Time `gorm:"column:updated_at;autoUpdateTime" json:"updated_at"`
}

func CreateTimestamp(createdBy string) Timestamp {
	return Timestamp{
		CreatedAt: time.Now(),
		CreatedBy: createdBy,
		UpdatedAt: time.Now(),
		UpdatedBy: createdBy,
	}
}

func (t *Timestamp) Update(updatedBy string) {
	t.UpdatedAt = time.Now()
	t.UpdatedBy = updatedBy
}
