# utilities.sh

function isTruthy() {
    case "$1" in
        "1" | "true" | "True" | "TRUE" | "yes" | "on")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

function isFalsy() {
    case "$1" in
        "" | "0" | "false" | "False" | "FALSE" | "no" | "off")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

