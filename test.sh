#!/usr/bin/env bash

checkExitCode() {
    script_path="$1"
    expected_code="$2"

    echo "▶️▶️▶️ $script_path needs $expected_code ◀️◀️◀️"

    bash "$script_path"
    exit_code="$?"
    if [ "$exit_code" -ne "$expected_code" ]; then
        echo "❌❌❌ Expected exit code $expected_code for $script_path, but got $exit_code"
        exit 1
    else
        echo "✅✅✅ exit code $expected_code for $script_path"
    fi

    echo
}

cd tests/

# Positive tests

CISH_DEBUG=1 \
CISH_INDENT_SIZE=4 \
CISH_PRINT_SYSTEM_INFO=1 \
  checkExitCode "./01_empty.sh" "0"

TEAMCITY_VERSION=1.0 \
  checkExitCode "./02_teamcity.sh" "0"
GITHUB_ACTIONS=true \
  checkExitCode "./03_github.sh" "0"
GITLAB_CI=true \
  checkExitCode "./04_gitlab.sh" "0"

# Negative tests

checkExitCode "./11_failsetup.sh" "123"
checkExitCode "./12_failrun.sh" "123"
checkExitCode "./13_failteardown.sh" "123"
