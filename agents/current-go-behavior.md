# Current Go App Behavior

This document captures the runtime behavior of the Go-based File Summoner app (main.go).

## Finder path lookup
- Uses AppleScript via `mack.Tell("Finder", ...)`.
- If no Finder windows are open, the path is the Desktop.
- Otherwise, the path is the target of Finder window 1.
- On failure, shows an error dialog and exits with code 1.

## Dialog flow
- Shows `mack.Dialog` with title "New Filename", prompt "Insert Filename", default "newFile.txt".
- If the dialog is canceled, the app exits with code 2.

## Sequoia "Legacy" workaround
- macOS Sequoia can return garbage text before the filename in AppleScript responses.
- The response is split by the string "Legacy".
- Filename selection rules:
  - 0 parts: exit with code 2.
  - 1 part: trimmed first part.
  - 2 parts: trimmed second part.
  - 3 parts: trimmed third part.
  - Default: exit with code 2.
- Limitation: filenames containing "Legacy" are incorrectly split.

## Filename validation
- Empty string is invalid.
- Invalid characters or sequences:
  - Contains "/".
  - Contains "..".
  - Contains a null byte ("\x00").
- If invalid, shows an error dialog and exits with code 1.
- Final filename is sanitized with `filepath.Base`.

## File creation
- Creates the file by running `touch` with the working directory set to the Finder path.
- On failure, shows an error dialog and exits with code 1.
- On success, logs "File Created" and exits normally.

## Logging
- Logs the resolved Finder path.
- Logs dialog result parts and length (for debugging the Sequoia workaround).
