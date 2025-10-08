#!/usr/bin/env bash

pkill -u "$USER" rofi && exit 0

cliphist_style="${ROFI_CLIPHIST_STYLE:-clipboard}"
del_mode=false

paste_string() {
    if ! command -v wtype >/dev/null; then exit 0; fi
    if [ -t 1 ]; then return 0; fi
    ignore_paste_file="$HYDE_STATE_HOME/ignore.paste"

    if [[ ! -e "${ignore_paste_file}" ]]; then
        cat <<EOF >"${ignore_paste_file}"
kitty
org.kde.konsole
terminator
XTerm
Alacritty
xterm-256color
EOF
    fi

    ignore_class=$(echo "$@" | awk -F'--ignore=' '{print $2}')
    [ -n "${ignore_class}" ] && echo "${ignore_class}" >>"${ignore_paste_file}" && print_log -y "[ignore]" "'$ignore_class'" && exit 0
    class=$(hyprctl -j activewindow | jq -r '.initialClass')
    if ! grep -q "${class}" "${ignore_paste_file}"; then
        hyprctl -q dispatch exec 'wtype -M ctrl V -m ctrl'
    fi
}

get_rofi_pos() {
    readarray -t curPos < <(hyprctl cursorpos -j | jq -r '.x,.y')
    eval "$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) |
        "monRes=(\(.width) \(.height) \(.scale) \(.x) \(.y)) offRes=(\(.reserved | join(" ")))"')"

    monRes[2]="${monRes[2]//./}"
    monRes[0]=$((monRes[0] * 100 / monRes[2]))
    monRes[1]=$((monRes[1] * 100 / monRes[2]))
    curPos[0]=$((curPos[0] - monRes[3]))
    curPos[1]=$((curPos[1] - monRes[4]))
    offRes=("${offRes// / }")

    if [ "${curPos[0]}" -ge "$((monRes[0] / 2))" ]; then
        local x_pos="east"
        local x_off="-$((monRes[0] - curPos[0] - offRes[2]))"
    else
        local x_pos="west"
        local x_off="$((curPos[0] - offRes[0]))"
    fi

    if [ "${curPos[1]}" -ge "$((monRes[1] / 2))" ]; then
        local y_pos="south"
        local y_off="-$((monRes[1] - curPos[1] - offRes[3]))"
    else
        local y_pos="north"
        local y_off="$((curPos[1] - offRes[1]))"
    fi

    local coordinates="window{location:${x_pos} ${y_pos};anchor:${x_pos} ${y_pos};x-offset:${x_off}px;y-offset:${y_off}px;}"
    echo "${coordinates}"
}

# process clipboard selections
process_selections() {
    if [ true != "${del_mode}" ]; then
        mapfile -t lines
        total_lines=${#lines[@]}

        # handle special commands
        if [[ "${lines[0]}" = ":d:e:l:e:t:e:"* ]]; then
            "${0}" --delete
            return
        elif [[ "${lines[0]}" = ":w:i:p:e:"* ]]; then
            "${0}" --wipe
            return
        elif [[ "${lines[0]}" = ":o:p:t:"* ]]; then
            "${0}"
            return
        fi

        # process regular clipboard items
        local output=""
        for ((i = 0; i < total_lines; i++)); do
            local line="${lines[$i]}"
            local decoded_line
            decoded_line="$(echo -e "$line\t" | cliphist decode)"
            if [ $i -lt $((total_lines - 1)) ]; then
                printf -v output '%s%s\n' "$output" "$decoded_line"
            else
                printf -v output '%s%s' "$output" "$decoded_line"
            fi
        done
        echo -n "$output"
    else
        while IFS= read -r line; do
            if [[ "${line}" = ":w:i:p:e:"* ]]; then
                "${0}" --wipe
                break
            elif [[ "${line}" = ":b:a:r:"* ]]; then
                "${0}" --delete
                break
            elif [ -n "$line" ]; then
                cliphist delete <<<"${line}"
                notify-send "Deleted" "${line}"
            fi
        done
        exit 0
    fi
}

# check if content is binary
check_content() {
    local line
    read -r line
    if [[ ${line} == *"[[ binary data"* ]]; then
        cliphist decode <<<"$line" | wl-copy
        local img_idx
        img_idx=$(awk -F '\t' '{print $1}' <<<"$line")
        local temp_preview="${XDG_RUNTIME_DIR}/hyde/pastebin-preview_${img_idx}"
        wl-paste >"${temp_preview}"
        notify-send -a "Pastebin:" "Preview: ${img_idx}" -i "${temp_preview}" -t 2000
        return 1
    fi
}

# execute rofi
run_rofi() {
    local placeholder="$1"
    shift
    rofi -dmenu \
        -theme-str "entry { placeholder: \"${placeholder}\";}" \
        -theme-str "${r_override}" \
        -theme-str "${rofi_position}" \
        -config ~/.config/rofi/clipboard.rasi \
        "$@"
}

# rofi config
setup_rofi_config() {
    # Window rounding
    local hypr_border=${hypr_border:-"$(hyprctl -j getoption decoration:rounding | jq '.int')"}
    local wind_border=$((hypr_border * 3 / 2))
    local elem_border=$((hypr_border == 0 ? 5 : hypr_border))

    # Rofi position
    rofi_position=$(get_rofi_pos)

    # Hyprland border size
    local hypr_width=${hypr_width:-"$(hyprctl -j getoption general:border_size | jq '.int')"}
    local width=$((hypr_width * 3 / 2))

    # Hyprland active border color with alpha
    local hypr_color_full
    hypr_color_full=$(hyprctl -j getoption general:col.active_border | jq -r '.custom' | awk '{print $1}')
    local hypr_color="#${hypr_color_full:2}"  # Remove 0x, keep RRGGBBAA

    # Rofi override string
    r_override="window{border:${width}px;border-radius:${wind_border}px;border-color:${hypr_color};} \
wallbox{border-radius:${elem_border}px;} \
element{border-radius:${elem_border}px;}"
}

# show clipboard history
show_history() {
    local selected_item
    selected_item=$( (
        echo -e ":o:p:t:\t⚙️ Options"
        cliphist list
    ) | run_rofi " 📜 History..." -multi-select -i -display-columns 2 -selected-row 2)

    [ -n "${selected_item}" ] || exit 0

    if echo -e "${selected_item}" | check_content; then
        process_selections <<<"${selected_item}" | wl-copy
        paste_string "${@}"
        echo -e "${selected_item}\t" | cliphist delete
    else
        paste_string "${@}"
        exit 0
    fi
}

# delete items
delete_items() {
    export del_mode=true
    cliphist list | run_rofi " 🗑️ Delete" -multi-select -i -display-columns 2 | process_selections
}

# clear clipboard history
clear_history() {
    local confirm
    confirm=$(echo -e "Yes\nNo" | run_rofi "☢️ Clear Clipboard History?")
    if [ "$confirm" = "Yes" ]; then
        cliphist wipe
        notify-send "Clipboard history cleared."
    fi
}

# help
show_help() {
    cat <<EOF
Options:
  -c  | --copy | History     Show clipboard history and copy selected item
  -d  | --delete | Delete    Delete selected item from clipboard history
  -w  | --wipe | Clear       Clear clipboard history
  -h  | --help | Help        Display this help message
EOF
    exit 0
}

# main
main() {
    setup_rofi_config
    local main_action
    if [ $# -eq 0 ]; then
        main_action=$(echo -e "History\nDelete\nClear History" |
            run_rofi "🔎 Choose action")
    else
        main_action="$1"
    fi

    case "${main_action}" in
    -c | --copy | "History")
        show_history "$@"
        ;;
    -d | --delete | "Delete")
        delete_items
        ;;
    -w | --wipe | "Clear History")
        clear_history
        ;;
    -h | --help | *)
        [ -z "$main_action" ] && exit 0
        show_help
        ;;
    esac
}

main "$@"
