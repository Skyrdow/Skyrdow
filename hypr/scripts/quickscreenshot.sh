#!/bin/bash
#  ____                               _           _
# / ___|  ___ _ __ ___  ___ _ __  ___| |__   ___ | |_
# \___ \ / __| '__/ _ \/ _ \ '_ \/ __| '_ \ / _ \| __|
#  ___) | (__| | |  __/  __/ | | \__ \ | | | (_) | |_
# |____/ \___|_|  \___|\___|_| |_|___/_| |_|\___/ \__|
#
#
# by Stephan Raabe (2023)
# -----------------------------------------------------

DIR="$HOME/Pictures/screenshots/"
NAME="screenshot_$(date +%d%m%Y_%H%M%S).png"

grim -g "$(slurp)" "$DIR$NAME"
xclip -selection clipboard -t image/png -i "$DIR$NAME"
notify-send "Screenshot created and copied to clipboard" "Mode: Selected area"
swappy -f "$DIR$NAME"
# esac
