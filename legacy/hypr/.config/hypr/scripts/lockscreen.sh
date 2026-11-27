#!/usr/bin/env bash

lockscreen="${LOCKSCREEN:-hyprlock}"

case ${1} in
    --get)
        echo "${lockscreen}"
        exit 0
        ;;    
esac

#? To cleanly exit hyprlock we should use a systemd scope unit.
#? This allows us to manage the lockscreen process more effectively.
#? This fix the zombie process issue when hyprlock is unlocked but still running.
unit_id=(-u "${LOCKSCREEN_SCOPE:-hyde-lockscreen.scope}")

if which "${lockscreen}.sh" 2>/dev/null 1>&2; then
    printf "Executing ${lockscreen} wrapper script : %s\n" "${lockscreen}.sh"
    /home/saiddis/.config/hypr/scripts/app2unit.sh  "${unit_id[@]}"  -- "${lockscreen}.sh" "${@}"
else
    printf "Executing raw command: %s\n" "${lockscreen}"
    /home/saiddis/.config/hypr/scripts/app2unit.sh "${unit_id[@]}" -- "${lockscreen}" "${@}"
fi
