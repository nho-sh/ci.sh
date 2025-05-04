# constants.sh

_CISH_RUNROOT=$(pwd -P)
_CISH_CI_SUITE="" # teamcity/github/gitlab

if [ "$TEAMCITY_VERSION" != "" ]; then
    _CISH_CI_SUITE="teamcity"
elif [ "$GITHUB_ACTIONS" = "true" ]; then
    _CISH_CI_SUITE="github"
elif [ "$GITLAB_CI" = "true" ]; then
    _CISH_CI_SUITE="gitlab"
fi
