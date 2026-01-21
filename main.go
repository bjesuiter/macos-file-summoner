package main

import (
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/andybrewer/mack"
)

func touchFile(path string, filename string) error {
	cmd := exec.Command("touch", filename)
	cmd.Dir = path
	return cmd.Run()
}

func main() {

	path, err := mack.Tell("Finder",
		"if (count of Finder windows) is 0 then",
		"set dir to (desktop as alias)",
		"else",
		"set dir to ((target of Finder window 1) as alias)",
		"end if",
		"return POSIX path of dir")
	if err != nil {
		panic(err)
	}

	log.Printf("Topmost finder path:  %s\n", path)

	response, err := mack.Dialog("New Filename", "Insert Filename", "newFile.txt")
	if err != nil {
		panic(err)
	}

	if response.Clicked == "Cancel" {
		// handle the Cancel event
		os.Exit(2)
	} else {
		dialogResult := strings.Split(response.Text, "Legacy")
		log.Printf("Dialog Result: %s", dialogResult)
		log.Printf("Dialog Result Length: %d", len(dialogResult))

		newFilename := ""
		switch len(dialogResult) {
		case 0:
			log.Printf("No filename provided")
			os.Exit(2)
		case 1:
			log.Printf("Filename provided: %s", dialogResult[0])
			newFilename = strings.TrimSpace(dialogResult[0])
		case 2:
			log.Printf("Filename provided: %s", dialogResult[1])
			newFilename = strings.TrimSpace(dialogResult[1])
		case 3:
			log.Printf("Filename provided: %s", dialogResult[2])
			newFilename = strings.TrimSpace(dialogResult[2])
		default:
			log.Printf("Unknown count for dialog result")
			os.Exit(2)
		}

		if newFilename == "" {
			mack.Alert("Error", "Filename cannot be empty")
			os.Exit(1)
		}

		if strings.Contains(newFilename, "/") || strings.Contains(newFilename, "..") || strings.Contains(newFilename, "\x00") {
			mack.Alert("Error", "Filename cannot contain path separators or special characters")
			os.Exit(1)
		}

		newFilename = filepath.Base(newFilename)

		err := touchFile(path, newFilename)
		if err != nil {
			panic(err)
		}
		log.Printf("File Created: %s", newFilename)
	}

}
