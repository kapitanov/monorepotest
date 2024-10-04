package main

import (
	"net/http"
	"time"

	"github.com/kapitanov/monorepotest/libs/contracts"
	"github.com/labstack/echo/v4"
)

func main() {
	e := echo.New()
	e.GET("/", func(c echo.Context) error {
		return c.JSON(http.StatusOK, contracts.NewTime(time.Now().UTC()))
	})
	_ = e.Start(":8081")
}
