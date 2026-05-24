#!/data/data/com.termux/files/usr/bin/bash

PET_DIR="${PET_DIR:-$HOME/.termux-pet}"

if [ ! -f "$PET_DIR/pet_state.sh" ]; then
    exit 0
fi

source "$PET_DIR/pet_state.sh"

state=$(read_state)

if [ "$state" != "visible" ]; then
    exit 0
fi

LAST_EXIT_CODE="${STARSHIP_CMD_STATUS:-${?}}"

mood=$(get_mood)
art=$(get_pet_art "$mood")
dialogue=$(get_mood_dialogue "$mood")

echo "${art} ${dialogue}"