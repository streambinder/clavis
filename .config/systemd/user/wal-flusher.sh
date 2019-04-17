#!/bin/bash

cd "${HOME}"

if ! test wal; then
	echo "Wal not installed. Skipping."
	exit
fi

cfg_wallpaper_path="${HOME}/.cache/wal/wallpaper.md5"
if [ -f "${cfg_wallpaper_path}" ]; then
	cfg_wallpaper_md5="$(cat ${cfg_wallpaper_path})"
fi

now_wallpaper_path="$(dconf dump /org/gnome/desktop/background/ | awk -F'file://' '/^picture-uri=/ {print $2}' | sed s/\'//g)"
if [ -z "${now_wallpaper_path}" ]; then
	echo "Unable to identify background image"
	exit
else
	now_wallpaper_md5="$(md5sum "${now_wallpaper_path}" | awk '{print $1}')"
fi

if [ "${cfg_wallpaper_md5}" = "${now_wallpaper_md5}" ]; then
	echo "Wal configuration files already up-to-date"
else
	wal -c
	wal -i "${now_wallpaper_path}" -n
	echo "${now_wallpaper_md5}" > "${cfg_wallpaper_path}"
	echo "Updated Wal configuration files"
fi
