# env.sh

: "${CISH_DEBUG:=}"
: "${CISH_ENTRY_MESSAGE:=Starting CI}"
: "${CISH_EXIT_MESSAGE:=bye.}"
: "${CISH_INDENT_SIZE:=2}"
: "${CISH_OUTPUT_DIR:=$_CISH_RUNROOT/ci-output}"
: "${CISH_OUTPUT_LOG:=$CISH_OUTPUT_DIR/ci.log}"
: "${CISH_PRINT_SYSTEM_INFO:=no}"
: "${CISH_PRINT_DURATION:=yes}"
: "${CISH_PRINT_EMOJI:=yes}"

# Debug log all values
if [ "$CISH_DEBUG" = 1 ]; then
    echo "CISH_DEBUG enabled"
    echo
    echo "CISH_DEBUG=$CISH_DEBUG"
    echo "CISH_ENTRY_MESSAGE=$CISH_ENTRY_MESSAGE"
    echo "CISH_EXIT_MESSAGE=$CISH_EXIT_MESSAGE"
    echo "CISH_OUTPUT_DIR=$CISH_OUTPUT_DIR"
    echo "CISH_OUTPUT_LOG=$CISH_OUTPUT_LOG"
    echo "CISH_PRINT_DURATION=$CISH_PRINT_DURATION"
    echo "CISH_PRINT_SYSTEM_INFO=$CISH_PRINT_SYSTEM_INFO"
fi

# Sense checks

# Is the output folder not something weird?
if [ "$CISH_OUTPUT_DIR" = "" ] || [ "$CISH_OUTPUT_DIR" = "/ci-output" ]; then
    echo "Something is wrong with setting up the output dir. This is wrong: '$CISH_OUTPUT_DIR'"
    exit 101
fi

# Make a build output folder if it does not exist yet
mkdir -p "$CISH_OUTPUT_DIR"

# Delete files in the output folder as best as we can
rm -rf $CISH_OUTPUT_DIR/* || true

# From this point on, all output is captured by exec
# and sent via tee to both file and the terminal
exec > >(tee "$CISH_OUTPUT_LOG") 2>&1
