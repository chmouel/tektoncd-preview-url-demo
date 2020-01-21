package main

import (
	"fmt"
	"log"
	"os"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

var (
	directory = "/opt/website"
	host      = "0.0.0.0"
	port      = "8080"
)

func main() {
	e := echo.New()

	if os.Getenv("PUBLIC_HTML") != "" {
		directory = os.Getenv("PUBLIC_HTML")
	}

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	e.Static("/", directory)

	err := e.Start(fmt.Sprintf("%s:%s", host, port))
	if err != nil {
		log.Fatal(err)
	}
}
