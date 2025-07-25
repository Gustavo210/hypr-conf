#!/bin/bash

WALLPAPERS_DIR="$HOME/.config/ml4w/wallpapers"

# Get a list of all image files in the wallpapers directory
WALLPAPERS=($(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \)))

# Check if there are any wallpapers
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPERS_DIR"
    exit 1
fi

# Get the current wallpaper from hyprctl
CURRENT_WALLPAPER=$(hyprctl hyprpaper list | grep 'Wallpaper' | awk '{print $3}')

# Pick a random wallpaper different from the current one
while : ; do
    RANDOM_INDEX=$((RANDOM % ${#WALLPAPERS[@]}))
    RANDOM_WALLPAPER="${WALLPAPERS[$RANDOM_INDEX]}"
    if [[ "$RANDOM_WALLPAPER" != "$CURRENT_WALLPAPER" ]]; then
        break
    fi
done

hyprctl hyprpaper preload "$RANDOM_WALLPAPER"

# Apply the same wallpaper to all monitors
for MONITOR in $(hyprctl monitors | grep 'Monitor' | awk '{print $2}'); do
    hyprctl hyprpaper wallpaper "$MONITOR,$RANDOM_WALLPAPER"
done

echo "Wallpaper changed to: $RANDOM_WALLPAPER on all monitors"