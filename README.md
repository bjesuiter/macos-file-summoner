# MacOS File Summoner

The macOS File Summoner is a little tool which is able to create new files directly from finder.
Simply drag this .app file onto the finder toolbar in edit mode (more detailed description later) and click the icon! :)

## Installation in Finder

Here is a link to the installation guide video:

<a href="http://www.youtube.com/watch?feature=player_embedded&v=iY6vKWqmnFg
" target="_blank"><img src="http://img.youtube.com/vi/iY6vKWqmnFg/0.jpg" 
alt="Link to a video explaining how to install macOS File Summoner App" width="240" height="180" border="10" /></a>

### Note on Permissions

MacOS MAY ask you for the following permissions:

- Controlling Finder: needed to find the active folder path in the finder window where 'File Summoner' was activated
- Access to locations on your disk (to create new files)

You need to grant both for the app to work.

### How to install - Text Instructions

1. Download the file 'File.Summoner.x.x.x.dmg' from the latest release of this software at [Github Latest Releases](https://github.com/bjesuiter/macos-file-summoner/releases/latest). The part x.x.x means the version number of the latest release.

2. Open the dmg file
3. Drag and drop the App to your macOS 'Applications' folder link inside the dmg
4. Add the app to your finder toolbar
   1. Open a new finder window
   2. Right click on a space section of the finder toolbar and click 'Adjust toolbar'
   3. Open a second finder Window and navigate to /Applications
   4. Drag the icon of `File Summoner.app` from the second finder window to the toolbar of the first,
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

---

# Changelog

## v1.2.0

- Completely signed and notarized app, which will run without security issues on your mac! \*️
- Distribution via beautiful, signed and notarized dmg file!

> \* ️
> As long as my apple developer certificate is valid.  
> Ways to support me will be available in the future, so that I can continue to pay the anual fee for the apple developer certificate.

## v1.1.0

- initial Release

---

# Readme for Developers

## New Version release

1. increase version in Info.plist & ./version file
2. Update changelog in Readme.md
3. Commit this changes as 'Release vx.x.x'
4. Tag this release with 'vx.x.x'
5. Upload this tag to github with 'git push --tags'
6. Adjust Release Publish on Github
   - generate another random Emoji to mark the release (for better readability)  
     https://perchance.org/emoji
   - Add Changes in this release

## Todos

- improve icon to better fit macOS Finder style
- Add i18n to the app based on the language of the host macos
- copy the string in ./version' into the 'Info.plist' file for the app to avoid manual version updating in Info.plist
- github actions build does not work when downloaded from github (no .app, no .dmg)
  - TODO: make zip of .app and notarize this => Test again
- Publish App in Mac App Store (https://developer.apple.com/macos/submit/)

## Ideas

- Implement a better designed 'new File' Dialog based on [Gio](https://gioui.org/)
- Add more 'File Creators' besides simple 'touch'
  - essential for Microsoft Office files
  - for example, creating my-document.docx with "File Summoner.app" currently results in a broken file
