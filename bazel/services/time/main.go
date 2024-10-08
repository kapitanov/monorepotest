package main

import (
	"log"
	"net/http"
	"time"

	"github.com/kapitanov/monorepotest/libs/contracts"
	"github.com/labstack/echo/v4"
)

var Version = "develop" //nolint:gochecknoglobals // It's OK.

func main() {
	e := echo.New()
	e.GET("/", func(c echo.Context) error {
		return c.JSON(http.StatusOK, contracts.NewTime(time.Now().UTC()))
	})

	const endpoint = ":8081"
	log.Printf("time service v%s is running at %q", Version, endpoint)
	err := e.Start(endpoint)
	if err != nil {
		log.Panic(err)
	}
}
