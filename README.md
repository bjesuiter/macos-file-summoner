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
- DMG created with [create-dmg by Sindre Sorhus](https://www.npmjs.com/package/create-dmg)
- App and DMG notarizations done with [mitchellh/gon](https://github.com/mitchellh/gon)

------------------------------------------------

# Changelog 

## next
- Completely signed and notarized app, which will run without security issues on your mac! *️⃣ 
- Distribution via beautiful,signed and notarized dmg file! 

*️⃣ 
The App will run flawlessly as long as my developer certificate is valid!
If I would have a Patreon or so, you could support me to ensure future validity of this certificate!  
Unfortunately, I don't have any pages in place yet for supporting me.  
But when I do, I'll let you know! 


## v1.1.0 
- initial Release 

------------------------------------------------

# Readme for Developers

## New Version release 
1. increase version in Info.plist & ./version
2. Update changelog in Readme.md 
3. Commit this changes as 'Release vx.x.x'
4. Tag this release with 'vx.x.x'
5. Upload this tag to github with 'git push --tags' 

## Todos
- improve icon to better fit macOS Finder style
- Add i18n to the app based on the language of the host macos 
- copy the string in ./version' into the 'Info.plist' file for the app to avoid manual version updating in Info.plist
- github actions build does not work when downloaded from github (no .app, no .dmg) 
    - TODO: make zip of .app and notarize this => Test again

## Ideas 
- Implement a better designed 'new File' Dialog based on [Gio](https://gioui.org/)
- Add more 'File Creators' besides simple 'touch' 
    - essential for Microsoft Office files
    - for example, creating my-document.docx with "File Summoner.app" currently results in a broken file