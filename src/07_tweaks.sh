# tweaks.sh

# Docker: do not use progress bars in CI, and flood the logs
export BUILDKIT_PROGRESS=plain

# No TTY connected?
if [ ! -t 1 ]; then
    # Do not use colored output if there is not TTY, only causes trouble
    export NO_COLOR=1

    # Simplify terminal output, to avoid trouble
    export TERM=dumb

    # TODO What else can we by default make better in non-TTY?
fi
