# header.sh

# ci.sh (https://github.com/nho-sh/ci.sh/)
# A single-file, batteries included, opinionated CI entrypoint bash script

# LICENSE: MIT
#   https://github.com/nho-sh/ci.sh/blob/main/LICENSE

# Sense check: are we running in bash? or something compatible?
if [ -z "$BASH_VERSION" ]; then
    echo "ci.sh only works in bash. (If you want to force run, set BASH_VERSION=dummy)"
    exit 100
fi
