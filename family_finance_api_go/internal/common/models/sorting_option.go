package models

type SortingOption struct {
	Field     string `json:"sort_field"`
	Direction string `json:"sort_direction"`
}

func NewSortingOption() *SortingOption {
	return &SortingOption{
		Field:     "",
		Direction: "asc",
	}
}
