package main

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/kapitanov/monorepotest/libs/contracts"
)

func main() {
	r := gin.Default()
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, contracts.NewDate(time.Now().UTC()))
	})
	_ = r.Run(":8082")
}
