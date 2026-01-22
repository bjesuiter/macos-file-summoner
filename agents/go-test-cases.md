# Go App Manual Test Cases

These manual scenarios reflect the current Go implementation behavior.

## Finder context
- Launch from Finder toolbar with at least one Finder window open.
- Launch from Finder toolbar with zero Finder windows open (Desktop fallback).

## Dialog interaction
- Dialog displays with default filename "newFile.txt" selected.
- Cancel button exits the app without creating a file.

## Filename validation
- Valid filename ("test.txt") creates a file.
- Filename with spaces ("my file.txt") creates a file.
- Empty filename shows error and exits.
- Filename containing "/" shows error and exits.
- Filename containing ".." shows error and exits.
- Filename containing a null byte shows error and exits.

## File creation errors
- Attempt to create file in a read-only directory shows error.
- Attempt to create a file that already exists shows error.

## Sequoia Legacy workaround
- Dialog response containing leading garbage text ending in "Legacy" still resolves to the intended filename.
