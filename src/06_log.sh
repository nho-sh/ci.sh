# log.sh

# Every active section that is begun, will be recorded here,
# so we know what it is, when we have an error.
ACTIVE_SECTION_FILE="/tmp/cish_lastblock_$( cksum <(pwd) | cut -f 1 -d ' ' )"

# Test if we can adjust this file or not
if touch "$ACTIVE_SECTION_FILE" 2>/dev/null; then
    rm -f "$ACTIVE_SECTION_FILE"
else
    # Disable this functionality, cannot write to /tmp :(
    ACTIVE_SECTION_FILE=""
fi

if isTruthy "$CISH_PRINT_EMOJI"; then
    _CISH_EMOJI_ERROR="❌"
    _CISH_EMOJI_WARN="⚠️"
    _CISH_EMOJI_BEGIN="🚀" # 🚀 🔷 ▶
    _CISH_EMOJI_END="🏁"
    _CISH_EMOJI_TOOLS="🛠️"
    _CISH_EMOJI_PC="🖥️"
    _CISH_EMOJI_CHRONO="⏱️"
else
    _CISH_EMOJI_ERROR="X"
    _CISH_EMOJI_WARN="!"
    _CISH_EMOJI_BEGIN=">"
    _CISH_EMOJI_END=""
    _CISH_EMOJI_TOOLS=""
    _CISH_EMOJI_PC=""
    _CISH_EMOJI_CHRONO=""
fi

# TODO: make this work, so that the base section headers are underlined
# # TTY active?
# if [ -t 1 ]; then
#     _CISH_UNDERLINE_OPEN="\033[4m"
#     _CISH_UNDERLINE_CLOSE="\033[0m"
# else
#     _CISH_UNDERLINE_OPEN=""
#     _CISH_UNDERLINE_CLOSE=""
# fi

if [ -n "$_CISH_CI_SUITE" ]; then
    function cishLog() {
        if [ "$1" != "" ]; then

            if [ "$_CISH_CI_SUITE" = 'teamcity' ]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') $*"

            elif [ "$_CISH_CI_SUITE" = 'github' ]; then
                # Timestamp the logs
                TS=$(date --iso-8601=s)
                echo "[$TS] $*"

            elif [ "$_CISH_CI_SUITE" = 'gitlab' ]; then
                # Timestamp the logs
                TS=$(date --iso-8601=s)
                echo "[$TS] $*"
            fi

        fi
    }
else
    # TODO: allow changing this line format or a flag to include the current time?
    function cishLog() {
       echo "$@"
    }
fi

_CISH_INDENT_LEVEL=0

if [ -n "$_CISH_CI_SUITE" ]; then
    function logSectionBegin() {
        if [ -n "$ACTIVE_SECTION_FILE" ]; then
            echo "$1" > "$ACTIVE_SECTION_FILE"
        fi

        if [ "$_CISH_CI_SUITE" = 'teamcity' ]; then
            echo "##teamcity[blockOpened name='$1']"

        elif [ "$_CISH_CI_SUITE" = 'github' ]; then
            echo "::block::$1"

        elif [ "$_CISH_CI_SUITE" = 'gitlab' ]; then
            echo -e "section_start:$(date +%s):$1\r"

        else
            echo "Start of $1"
        fi
    }
    function logSectionEnd() {
        if [ "$_CISH_CI_SUITE" = 'teamcity' ]; then
            echo "##teamcity[blockClosed name='$1']"

        elif [ "$_CISH_CI_SUITE" = 'github' ]; then
            echo "::endgroup::"

        elif [ "$_CISH_CI_SUITE" = 'gitlab' ]; then
            echo -e "section_end:$(date +%s):$1\r"

        else
            echo "End of $1"
        fi
    }
else
   function logSectionBegin() {
        local label="$1"

        if [ -n "$ACTIVE_SECTION_FILE" ]; then
            echo "$1" > "$ACTIVE_SECTION_FILE"
        fi

        printf "%*s$_CISH_EMOJI_BEGIN %s $_CISH_EMOJI_BEGIN\n" $((_CISH_INDENT_LEVEL * CISH_INDENT_SIZE)) "" "$label"
        ((_CISH_INDENT_LEVEL++))
   }
   function logSectionEnd() {
        ((_CISH_INDENT_LEVEL--))
        local label="$1"
        printf "%*s$_CISH_EMOJI_END %s $_CISH_EMOJI_END\n" $((_CISH_INDENT_LEVEL * CISH_INDENT_SIZE)) "" "$label"
   }
fi

function _cishGetLastSection() {
    if [ -n "$ACTIVE_SECTION_FILE" ]; then
        cat "$ACTIVE_SECTION_FILE"
    else
        echo "(failed to detect)"
    fi
}
