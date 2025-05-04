#!/bin/bash

function cish_setup() {
    echo "ok"
}

function cish_run() {
    echo "Run ok"
}

function cish_teardown() {
    return 123
}

source "../ci.sh"
