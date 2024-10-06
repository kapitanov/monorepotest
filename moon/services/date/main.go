package main

import (
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/kapitanov/monorepotest/libs/contracts"
)

var Version = "develop" //nolint:gochecknoglobals // It's OK.

func main() {
	gin.SetMode(gin.ReleaseMode)

	r := gin.Default()
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, contracts.NewDate(time.Now().UTC()))
	})

	const endpoint = ":8082"
	log.Printf("date service v%s is running at %q", Version, endpoint)
	err := r.Run(endpoint)
	if err != nil {
		log.Panic(err)
	}
}
