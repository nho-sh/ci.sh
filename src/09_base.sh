# base.sh

cishLog "$CISH_ENTRY_MESSAGE"

# Check if output folder exists
if [ ! -d "$CISH_OUTPUT_DIR" ]; then
    # TODO: test if we can write to the folder
    cishLog "$CISH_OUTPUT_DIR does not exist. mkdir it first"
    exit 102
fi


# Default missing functions
type -t cish_setup > /dev/null
if [ "$?" != "0" ]; then
    function cish_setup() {
        cishLog "$_CISH_EMOJI_WARN cish_setup is not defined, skipped"
    }
fi

type -t cish_run > /dev/null
if [ "$?" != "0" ]; then
    function cish_run() {
        cishLog "$_CISH_EMOJI_WARN cish_run is not defined, skipped"
    }
fi

type -t cish_teardown > /dev/null
if [ "$?" != "0" ]; then
    function cish_teardown() {
        cishLog "$_CISH_EMOJI_WARN cish_teardown is not defined, skipped"
        if [ "$1" != "" ]; then
            cishLog "  but there was an error: $0" # $0 = exit code
        fi
    }
fi

# Variables
SETUP_EXIT_CODE=0
SETUP_SUMMARY=""
RUN_EXIT_CODE=0
RUN_SUMMARY=""
TEARDOWN_EXIT_CODE=0
TEARDOWN_SUMMARY=""

{
    logSectionBegin 'Setup'

    printSystemInfo

    cish_setup
    SETUP_EXIT_CODE=$?

    if [ "$SETUP_EXIT_CODE" -eq 0 ]; then
        cishLog "Setup okay"
        SETUP_SUMMARY="$_CISH_EMOJI_OKAY"
    else
        SETUP_SUMMARY="$_CISH_EMOJI_ERROR"

        if [ "$_CISH_CI_SUITE" = 'teamcity' ]; then
            # Teamcity compatible message
            # https://www.jetbrains.com/help/teamcity/service-messages.html#Reporting+Build+Status
            echo "##teamcity[message text='Setup failed in $(_cishGetLastSection exitcode=$SETUP_EXIT_CODE)' errorDetails='See lines above' status='ERROR']"

            # TODO: add gitlab/github

        else
            cishLog "$_CISH_EMOJI_ERROR Setup failed in $(_cishGetLastSection exitcode=$SETUP_EXIT_CODE)"

        fi
    fi

    logSectionEnd 'Setup'
}

echo # add some whitespace in the logs

{
    # Only run if setup didn't error
    if [ "$SETUP_EXIT_CODE" = "0" ]; then
        logSectionBegin 'Run'

        cish_run
        RUN_EXIT_CODE=$?

        if [ "$RUN_EXIT_CODE" = "0" ]; then
            cishLog "Run successful"
            RUN_SUMMARY="$_CISH_EMOJI_OKAY"
        else
            RUN_SUMMARY="$_CISH_EMOJI_ERROR"

            if [ "$_CISH_CI_SUITE" = 'teamcity' ]; then
                # Teamcity compatible message
                # https://www.jetbrains.com/help/teamcity/service-messages.html#Reporting+Build+Status
                echo "##teamcity[message text='Run failed in $(_cishGetLastSection exitcode=$RUN_EXIT_CODE)' errorDetails='See lines above' status='ERROR']"

                # TODO: add gitlab/github

            else
                cishLog "$_CISH_EMOJI_ERROR Run failed in $(_cishGetLastSection exitcode=$RUN_EXIT_CODE)"

            fi
        fi

        logSectionEnd 'Run'
    else
        cishLog "$_CISH_EMOJI_WARN Run skipped, there is an error"
    fi
}

echo # add some whitespace in the logs

{
    logSectionBegin "Teardown"

    # Always run teardown, but pass error message
    # to teardown function
    #
    # The teardown does not need a subshell, because it should not be running
    # with `set -e` anyway, so that it can clean up and log as much as possible
    # By not running in a subshell, any bug in the teardown step will be immediatly visible
    cish_teardown "$SETUP_EXIT_CODE" "$RUN_EXIT_CODE"
    TEARDOWN_EXIT_CODE=$?

    if [ "$TEARDOWN_EXIT_CODE" = "0" ]; then
        cishLog "Teardown okay"
        TEARDOWN_SUMMARY="$_CISH_EMOJI_OKAY"
    else
        TEARDOWN_SUMMARY="$_CISH_EMOJI_ERROR"

        if [ "$_CISH_CI_SUITE" = 'teamcity' ]; then
            # Teamcity compatible message
            # https://www.jetbrains.com/help/teamcity/service-messages.html#Reporting+Build+Status
            echo "##teamcity[message text='Teardown failed in $(_cishGetLastSection exitcode=$TEARDOWN_EXIT_CODE)' errorDetails='See lines above' status='ERROR']"

            # TODO: add gitlab/github

        else
            cishLog "$_CISH_EMOJI_ERROR Teardown failed in $(_cishGetLastSection exitcode=$TEARDOWN_EXIT_CODE)"

        fi

    fi

    logSectionEnd 'Teardown'
}

echo # whitespace for clarity

# Calculate how long it ran
if isTruthy "$CISH_PRINT_DURATION"; then
    DURATION=$SECONDS
    cishLog "Finished after $(($DURATION / 60))m $(($DURATION % 60))s $_CISH_EMOJI_CHRONO"
fi

# Log an additional exit message if defined
if [ "$CISH_EXIT_MESSAGE" != "" ]; then
    cishLog "$CISH_EXIT_MESSAGE"
fi

echo "S:$SETUP_SUMMARY R:$RUN_SUMMARY T:$TEARDOWN_SUMMARY"

# coalesce with teardown exit code
FINAL_EXIT_CODE=0
[ $SETUP_EXIT_CODE -ne 0 ] && FINAL_EXIT_CODE=$SETUP_EXIT_CODE
[ $RUN_EXIT_CODE -ne 0 ] && FINAL_EXIT_CODE=$RUN_EXIT_CODE
[ $TEARDOWN_EXIT_CODE -ne 0 ] && FINAL_EXIT_CODE=$TEARDOWN_EXIT_CODE
return $FINAL_EXIT_CODE
