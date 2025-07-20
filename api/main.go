package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/go-redis/redis/v7"
	"github.com/gofiber/fiber/v2"
	_ "github.com/lib/pq"
)

func main() {
	app := fiber.New()

	app.Get("/test", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	app.Get("/db-check", func(c *fiber.Ctx) error {
		dbUser := os.Getenv("DB_USER")
		dbPass := os.Getenv("DB_PASSWORD")
		dbHost := os.Getenv("DB_HOST")
		dbPort := os.Getenv("DB_PORT")
		dbName := os.Getenv("DB_NAME")

		conn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
			dbHost, dbPort, dbUser, dbPass, dbName)

		log.Printf("Connecting to DB: %s", conn)

		db, err := sql.Open("postgres", conn)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).SendString("Failed to open connection: " + err.Error())
		}
		defer db.Close()

		err = db.Ping()
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).SendString("Failed to ping DB: " + err.Error())
		}

		return c.SendString("Successfully connected to Aurora PostgreSQL")
	})

	app.Get("/redis-check", func(c *fiber.Ctx) error {
		redisHost := os.Getenv("REDIS_HOST")
		redisPort := os.Getenv("REDIS_PORT")

		conn := fmt.Sprintf("%s:%s", redisHost, redisPort)

		log.Printf("Connecting to Redis: %s", conn)

		redisClient := redis.NewClient(&redis.Options{
			Addr:     conn,
			Password: "",
			DB:       0,
		})

		_, err := redisClient.Ping().Result()
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).SendString("Failed to ping Redis: " + err.Error())
		}

		return c.SendString("Successfully connected to Redis")
	})

	app.Get("/healthz", func(c *fiber.Ctx) error {
		return c.SendString("OK")
	})

	port := "8080"
	log.Printf("Starting server on port %s", port)
	log.Fatal(app.Listen(":" + port))
}
