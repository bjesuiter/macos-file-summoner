# MacOS File Summoner

The macOS File Summoner is a little tool which is able to create new files directly from finder. 
Simply drag this .app file onto the finder toolbar in edit mode (more detailed description later) and click the icon! :) 

## Installation in Finder 

1. Go to the [Releases](https://github.com/bjesuiter/macos-file-summoner/releases) section of this github repo 
   and download the 'File.Summoner.app.zip' file from the latest release. 
2. Extract the zip file
3. Copy the extracted .app file to your macOS 'Programs' folder 
4. Add the app to your finder toolbar
    1. Open a new finder window 
    2. Right click on a space section of the finder toolbar and click 'Adjust toolbar'
    3. Open a second finder Window and navigate to /Applications
    4. Drag the icon of `File Summoner.app ` from the second finder window to the toolbar of the first, 
    to the location where you want to have the icon for creating a new file. 
5. Enjoy the ability to create arbitrary files from the toolbar of your finder! 🎉

## Used Libraries & Tutorials

- Communicating with osascript from golang: [mack](https://github.com/andybrewer/mack)
- [Bundling go applications for mac (Medium Article)](https://medium.com/@mattholt/packaging-a-go-application-for-macos-f7084b00f6b5)
- Create file with touch: https://golang.org/pkg/os/exec/

## Attributions
- "Icon made by Pixel perfect from www.flaticon.com"
- Iconset generated with http://www.img2icnsapp.com/

------------------------------------------------

# Changelog 

## next
- Fixes Problem with release build on github
- switch to dmg for deployment

## v1.1.0 
- initial Release 

------------------------------------------------

# Readme for Developers

## New Version release 
1. increase version in Info.plist 
2. Update changelog in Readme.md 
3. Commit this changes as 'Release vx.x.x'
4. Tag this release with 'vx.x.x'
5. Upload this tag to github with 'git push --tags' 

## Todos
- improve icon to better fit macOS Finder style
- Add i18n to the app based on the language of the host macos 

## Ideas 
- Implement a better designed 'new File' Dialog based on [Gio](https://gioui.org/)