#!/bin/bash

function cish_setup() {
    echo "ok"
}

function cish_run() {
    return 123
}

function cish_teardown() {
  echo "Teardown ok"
}

source "../ci.sh"
