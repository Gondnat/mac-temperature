#!/bin/sh
productName="Temperature"

cd `dirname $0`

#building
rm -fr ./Release
xcodebuild -project $productName.xcodeproj DSTROOT=./Release SKIP_INSTALL=NO -scheme $productName -configuration Release clean install

#make dmg file
rm -fr ./$productName.dmg
ln -s /Applications ./Release/Applications
hdiutil create -ov -volname $productName -srcfolder ./Release/Applications ./$productName".dmg"
