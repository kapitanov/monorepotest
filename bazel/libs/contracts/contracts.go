package contracts

import "time"

type Time struct {
	Value string `json:"value"`
}

func NewTime(value time.Time) Time {
	return Time{
		Value: value.Format(time.TimeOnly),
	}
}

type Date struct {
	Value string `json:"value"`
}

func NewDate(value time.Time) Time {
	return Time{
		Value: value.Format(time.DateOnly),
	}
}
