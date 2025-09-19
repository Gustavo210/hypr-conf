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

# Remove current wallpaper from the list
FILTERED_WALLPAPERS=()
for wp in "${WALLPAPERS[@]}"; do
    if [[ "$wp" != "$CURRENT_WALLPAPER" ]]; then
        FILTERED_WALLPAPERS+=("$wp")
    fi
done

if [ ${#FILTERED_WALLPAPERS[@]} -eq 0 ]; then
    echo "Only one wallpaper available, already in use."
    exit 0
fi

# Pick a random wallpaper
RANDOM_INDEX=$((RANDOM % ${#FILTERED_WALLPAPERS[@]}))
RANDOM_WALLPAPER="${FILTERED_WALLPAPERS[$RANDOM_INDEX]}"

hyprctl hyprpaper preload "$RANDOM_WALLPAPER"

# Apply the same wallpaper to all monitors
for MONITOR in $(hyprctl monitors | grep 'Monitor' | awk '{print $2}'); do
    hyprctl hyprpaper wallpaper "$MONITOR,$RANDOM_WALLPAPER"
done

echo "Wallpaper changed to: $RANDOM_WALLPAPER on all monitors"