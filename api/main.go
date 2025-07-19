package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	http.HandleFunc("/db-check", func(w http.ResponseWriter, r *http.Request) {
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
			http.Error(w, "Failed to open connection: "+err.Error(), http.StatusInternalServerError)
			return
		}
		defer db.Close()

		err = db.Ping()
		if err != nil {
			http.Error(w, "Failed to ping DB: "+err.Error(), http.StatusInternalServerError)
			return
		}

		fmt.Fprintln(w, "Successfully connected to Aurora PostgreSQL 🎉")
	})

	port := "8080"
	log.Printf("Starting server on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
