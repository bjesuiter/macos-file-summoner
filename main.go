package main

import (
	"log"
	"os"
)
import "github.com/andybrewer/mack"
import "os/exec"

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
		newFilename := response.Text
		err := touchFile(path, newFilename)
		if err != nil {
			panic(err)
		}
		log.Printf("File Created: %s",newFilename)
	}

}
