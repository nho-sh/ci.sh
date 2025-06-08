# ci.sh

> A single-file, batteries included, opinionated CI entrypoint bash script

## Installation

```sh
curl -fsSL "https://raw.githubusercontent.com/nho-sh/ci.sh/main/ci.sh" -o ci.sh && chmod +x ci.sh
```

```sh
wget -qO ci.sh "https://raw.githubusercontent.com/nho-sh/ci.sh/main/ci.sh" && chmod +x ci.sh
```

### Extra installation options

- Only download if `ci.sh` is missing, prefix with:
  `[ -f ci.sh ] || `
- Only download if `ci.sh` is missing, or a day or more old:
  `[ -f ci.sh ] && [ "$(find ci.sh -mtime -1)" ] || `

## Skeleton script

```sh
#!/bin/bash

curl -fsSL "https://raw.githubusercontent.com/nho-sh/ci.sh/main/ci.sh" -o ci.sh && chmod +x ci.sh

function cish_setup() {
    echo "Setup ok"

    # Properly failing if a required step fails
    # by using fallthroughs (same in run/teardown)
    #    || return <exitcode>
    echo "Haystack" | grep "needle" || return 1

}

function cish_run() {
    echo "Run ok"
}

function cish_teardown() {
    echo "Teardown ok"
    # $1 is the cish_setup exit code
    # $2 is the cish_run exit code
}

source "./ci.sh"
```

## Features

- Flexible erorr handling
  - By default, non-zero exit codes are accepted. To change how a stage behaves, use `set -e`.
- Three stage setup/run/teardown
  - If `cish_setup` or `cish_run` fails, the `cish_teardown` step will run anyway.
- Structured and nested output in user definable sections
  - `logSectionBegin "MySection"` + `logSectionEnd "MySection"`
- Stage output and exit codes are inspectable in later stages. See below in section `State inspection`

## Helper functions

| Name + Arguments | Description |
| --- | --- |
| `cishFileExists "..."` | Check if a file exists. Great to assert that a CI step has expected output. Recommended to be called after `set -e` in `cish_teardown` |
| `cishFileNotExists "..."` | Opposite of `cishFileExists` |
| `cishFileEmpty "..."` | Check if a file exists AND is empty |
| `cishFileNotEmpty "..."` | Check if a file exists AND is NOT empty |
| `cishLog "..." "..." "..."` | Like `echo`, but CI friendlier |
| `cishUserNotification "..."`| Shows a popup notification, using your windowing system. Best effort. |

## ENV Configuration

The following values can be changed to your liking.

| ENV Key | Description | Default |
| --- | --- | --- |
| `CISH_DEBUG` | Print all `ci.sh` debug logs | `<empty>` |
| `CISH_ENTRY_MESSAGE` | Welcome message at the start of the output | `"Starting CI"` |
| `CISH_EXIT_MESSAGE` | Final message of `ci.sh` | `"bye."` |
| `CISH_INDENT_SIZE` | Number of spaces to indent. This only applies to `ci.sh` skeleton logs and not your CI steps. | `2` |
| `CISH_OUTPUT_DIR` | A prepared folder that can hold various output files and artifacts. Will be cleared each run. | `<Current working directory>/ci-output/` |
| `CISH_OUTPUT_LOG` | The full `ci.sh` output will be written here for logging purposes | `<Current working directory>/ci-output/ci.log` |
| `CISH_PRINT_DURATION` | Print a duration summary at the end? | `"yes"` |
| `CISH_PRINT_SYSTEM_INFO` | Output a verbose system summary, including various installed tool versions and system parameters | `"no"` |

## State inspection

- `ERROR_MESSAGE_SETUP`
- `ERROR_MESSAGE_RUN`
- `ERROR_MESSAGE_TEARDOWN`
- `SETUP_EXIT_CODE`
- `RUN_EXIT_CODE`
- `TEARDOWN_EXIT_CODE`

Note: internal values are prefixed with `_CISH_...` and should be left alone.

## Error exit codes

These exit codes are indicative. Your own implementation that results in exit codes,
can redefine the meaning of these codes.

| Code | Reason |
| --- | --- |
| `100` | `ci.sh` is not executed in `bash` |
| `101` | Funky looking output directory. For safety, execution will stop, because `ci.sh` will attempt to delete all files in the output folder |
| `102` | `ci.sh` is unable to prepare the output folder (mkdir it) |

## Development & testing

Install the VsCode extensions. The build is automated using extension "Run On Save".
See the VsCode Output window and focus on "Run On Save".
