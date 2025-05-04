#!/bin/bash

function cish_setup() {
    sleep 0.4s
    echo "ok"
}

function cish_run() {
    sleep 0.4s
    echo "Run ok"
}

function cish_teardown() {
    sleep 0.4s
    echo "Teardown ok"
}

source "../ci.sh"
