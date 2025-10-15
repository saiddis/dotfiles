#!/usr/bin/env bash
set -euo pipefail

# Directories
scrDir=${scrDir:-$HOME/hyde}
confDir="${confDir:-$XDG_CONFIG_HOME}"

USAGE() {
  cat <<EOF
Usage: $(basename "${0}") --[arg]

arguments:
  --mpris <player>   - Handles mpris thumbnail generation
                        : \$MPRIS_IMAGE
  --profile          - Generates the profile picture
                        : \$PROFILE_IMAGE
  --cava             - Placeholder function for cava
                        : \$CAVA_CMD
  --art              - Prints the path to the mpris art
                        : \$MPRIS_ART
  --help       -h    - Displays this help message
EOF
}

fn_profile() {
  local profilePath="/tmp/hyprlock-profile"
  if [ -f "$HOME/.face.icon" ]; then
    cp "$HOME/.face.icon" "${profilePath}.png"
  else
    cp "$XDG_DATA_HOME/icons/Wallbash-Icon/hyde.png" "${profilePath}.png"
  fi
  echo "${profilePath}.png"
}

fn_mpris() {
  local player=${1:-$(playerctl --list-all 2>/dev/null | head -n 1)}
  local thumb="/tmp/hyprlock-mpris"
  local player_status
  player_status="$(playerctl -p "${player}" status 2>/dev/null || true)"

  if [[ "${player_status}" == "Playing" ]]; then
    playerctl -p "${player}" metadata --format "{{xesam:title}} $(mpris_icon "${player}")  {{xesam:artist}}"
    mpris_thumb "${player}" "${thumb}"
    # pkill -USR2 hyprlock >/dev/null 2>&1 # updates the mpris thumbnail
  else
    cp -f "$HOME/.face.icon" "${thumb}.png"
    exit 1
  fi
}

mpris_icon() {
  local player=${1:-default}
  declare -A player_dict=(
    ["default"]=""
    ["spotify"]=""
    ["firefox"]=""
    ["vlc"]="嗢"
    ["google-chrome"]=""
    ["opera"]=""
    ["brave"]=""
  )
  for key in "${!player_dict[@]}"; do
    if [[ ${player} == "$key"* ]]; then
      echo "${player_dict[$key]}"
      return
    fi
  done
  echo ""
}

mpris_thumb() {
  local player=${1:-""}
  local thumb="${2:-/tmp/hyprlock-mpris}"
  local artUrl
  artUrl=$(playerctl -p "${player}" metadata --format '{{mpris:artUrl}}' || true)
  if [ -n "$artUrl" ]; then
    curl -Ls -o "${thumb}.art" "$artUrl"
    magick "${thumb}.art" -quality 50 "${thumb}.png"
    # pkill -USR2 hyprlock >/dev/null 2>&1 # updates the mpris thumbnail
  fi
}

fn_cava() {
  local tempFile=/tmp/hyprlock-cava
  [ -f "${tempFile}" ] && tail -n 1 "${tempFile}"
  config_file="${XDG_RUNTIME_DIR}/hyde/cava.hyprlock"
  if [ "$(pgrep -c -f "cava -p ${config_file}")" -eq 0 ]; then
    trap 'rm -f ${tempFile}' EXIT
    "$scrDir/cava.py" hyprlock >"${tempFile}" 2>&1
  fi
}

fn_art() {
  echo "/tmp/hyprlock-mpris.art"
}

# CLI parsing
LONGOPTS="mpris:,profile,cava,art,help"

PARSED=$(
  if ! getopt --options h --longoptions $LONGOPTS --name "$0" -- "$@"; then
    exit 2
  fi
)
eval set -- "$PARSED"

while true; do
  case "$1" in
    mpris|--mpris)
      fn_mpris "${2}"
      exit 0
      ;;
    profile|--profile)
      fn_profile
      exit 0
      ;;
    cava|--cava)
      fn_cava
      exit 0
      ;;
    art|--art)
      fn_art
      exit 0
      ;;
    help|-h|--help)
      USAGE
      exit 0
      ;;
    --) shift; break ;;
    *) break ;;
  esac
  shift
done
