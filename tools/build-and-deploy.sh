#!/bin/sh

# set -e

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/4.0-rc2/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --headless --export-debug "Linux/X11" build/linux/ld-53.x86_64 -v
# echo "EXPORTING FOR OSX"
# echo "-----------------------------"
# godot --export "Mac OSX" build/osx/ld-53.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --headless --export-debug "Windows Desktop" build/win/ld-53.exe -v
echo "-----------------------------"

# echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
# echo "-----------------------------"
# cd build/osx/
# mv ld-53.dmg ld-53-osx-alpha.zip
# unzip ld-53-osx-alpha.zip
# rm ld-53-osx-alpha.zip
# chmod +x ld-53.app/Contents/MacOS/ld-53
# zip -r ld-53-osx-alpha.zip ld-53.app
# rm -rf ld-53.app
# cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r ld-53-win-alpha.zip ld-53.exe ld-53.pck
rm -r ld-53.exe ld-53.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r ld-53-linux-alpha.zip ld-53.x86_64 ld-53.pck
rm -r ld-53.x86_64 ld-53.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/godot-template:linux-alpha
# butler push build/osx/ synsugarstudio/godot-template:osx-alpha
butler push build/win/ synsugarstudio/godot-template:win-alpha
