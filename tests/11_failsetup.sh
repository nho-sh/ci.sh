#!/bin/bash

function cish_setup() {
    echo "good" | grep bad || return 123
}

function cish_run() {
    echo "Run ok"
}

function cish_teardown() {
  echo "Teardown ok"
}

source "../ci.sh"
