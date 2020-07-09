#!/bin/bash

#07052019

url=https://www.bing.com
cd $(dirname $0)

#get DBUS_SESSION_BUS_ADDRESS (not set if run from cron)
[ -z $DBUS_SESSION_BUS_ADDRESS ] &&
  export $(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -n plasmashell)/environ)

#if any commandline option passed, then just show a random picture
[ -n "$1" ] && img=$(ls *.jpg|sort -R|tail -n 1) ||
    #otherwise get wallpaper url
    img=$(wget -t2 -T10 -qO - $url|sed 's:["\x27&\\]:\n:g'|grep -m1 "^/th?id=.*\.jpg")
    #/th?id=OHR.PeelCastle_EN-US6180948507_1920x1080.jpg

#if img and no commandline option, download wallpaper
[ -n "$img" ] && [ -z "$1" ] && wget -qN $url$img -O ${img#/*.}

#local image path/file
img=$(pwd)/${img#/*.}

#if no img for some reason (wget failed), quit
[ -f "$img" ] || exit 1

#kde neon, plasma 5+
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var allDesktops = desktops();
for (i=0;i<allDesktops.length;i++) {
d = allDesktops[i];
d.wallpaperPlugin = "org.kde.image";
d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
d.writeConfig("Image", "file://'$img'")}'

