package main

import (
	"log"
)
import "github.com/andybrewer/mack"

func main() {

	out, err := mack.Tell("Finder",
		"if (count of Finder windows) is 0 then",
		"set dir to (desktop as alias)",
		"else",
		"set dir to ((target of Finder window 1) as alias)",
		"end if",
		"return POSIX path of dir")
	if err != nil {
		log.Fatalf("Error:  %s", err)
	}

	log.Printf("Topmost finder path:  %s\n", out)
}
