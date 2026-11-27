floating=$(hyprctl activewindow -j | jq '.floating')
window=$(hyprctl activewindow -j | jq '.initialClass' | tr -d ' "')

function toggle() {
    width=$1
    height=$2
    hyprctl --batch "dispatch togglefloating; dispatch resizeactive exact ${width} ${height}; dispatch centerwindow"
}

function untoggle() {
    hyprctl dispatch togglefloating
}

function handle() {
    if [ "$floating" == "false" ]; then
        toggle "50%" "55%"
    else
        untoggle
    fi
}

case $window in
    kitty) handle ;;
    *) handle "80%" "75%" ;;
esac
