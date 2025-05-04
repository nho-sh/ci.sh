# utilities.sh

function printSystemInfo {
    # User wants it printed?
    if isFalsy "$CISH_PRINT_SYSTEM_INFO"; then
        return 0
    fi

    function printVersion() {
        local name="$1"
        shift

        if command -v "$name" >/dev/null 2>&1; then
            echo "$name: $("$@" 2>&1 | head -n 3)"
            echo
        fi
    }

    logSectionBegin 'System Info'

    logSectionBegin "$_CISH_EMOJI_TOOLS Installed applications"

    printVersion node node --version
    printVersion npm npm --version
    printVersion java java -version
    printVersion docker docker --version
    printVersion git git --version
    printVersion make make --version
    printVersion gcc gcc --version
    printVersion python3 python3 --version

    logSectionEnd "$_CISH_EMOJI_TOOLS Installed applications"

    logSectionBegin "$_CISH_EMOJI_PC Running environment"

    echo "Working dir:   $(pwd)"
    echo "Current user:  $USER ($UID) / $(id -g -n) ($(id -g))"

    echo "Hostname:      $(hostname)"
    echo "OS:            $(uname -a)"
    echo "Kernel:        $(uname -r)"
    echo "Architecture:  $(uname -m)"
    echo "Uptime:        $(uptime -p 2>/dev/null || uptime)"
    # TODO: nice memory/disk summary

    logSectionEnd "$_CISH_EMOJI_PC Running environment"

    logSectionEnd 'System Info'
}

function cishFileExists() {
    [ -f "$1" ]
}

function cishFileNotExists() {
    [ ! -f "$1" ]
}
function cishFileEmpty() {
    [ -f "$1" ] && [ ! -s "$1" ]
}

function cishFileNotEmpty() {
    [ -f "$1" ] && [ -s "$1" ]
}

function cishUserNotification {
    cishLog "$1"

    MSG="$1"

    # Subshell, so failure here is not a showstopper
    (
        # Only execute command if it exists

        # linux
        if command -v notify-send >/dev/null 2>&1; then
            notify-send --hint=int:transient:1 "$MSG"

        # mac
        elif command -v terminal-notifier >/dev/null 2>&1; then
            terminal-notifier -title "ci.sh" -message "$MSG"

        # mac fallback using AppleScript (no dependencies)
        elif [ "$(uname)" = "Darwin" ]; then
            osascript -e "display notification \"$MSG\" with title \"ci.sh\""

        fi

    ) || true
}
