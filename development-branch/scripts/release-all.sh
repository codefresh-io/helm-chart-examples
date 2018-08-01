#!/bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

function release_common_simplepod {
    local version_suffix="$1"
    cd $DIR/../common/simplepod/
    $DIR/../scripts/update-reqs.sh
    $DIR/../scripts/gather-deps.sh
    local version="$(cat Chart.yaml | grep 'version:' | awk '{print $2}')"
    helm push . --version="${version}${version_suffix}" codefresh
}

function release_app1 {
    local version_suffix="$1"
    cd $DIR/../apps/app1/
    $DIR/../scripts/update-reqs.sh
    $DIR/../scripts/gather-deps.sh
    local version="$(cat Chart.yaml | grep 'version:' | awk '{print $2}')"
    helm push . --version="${version}${version_suffix}" codefresh
}

function release_app2 {
    local version_suffix="$1"
    cd $DIR/../apps/app2/
    $DIR/../scripts/update-reqs.sh
    $DIR/../scripts/gather-deps.sh
    local version="$(cat Chart.yaml | grep 'version:' | awk '{print $2}')"
    helm push . --version="${version}${version_suffix}" codefresh
}

function release_app3 {
    local version_suffix="$1"
    cd $DIR/../apps/app3/
    $DIR/../scripts/update-reqs.sh
    $DIR/../scripts/gather-deps.sh
    local version="$(cat Chart.yaml | grep 'version:' | awk '{print $2}')"
    helm push . --version="${version}${version_suffix}" codefresh
}

function release_self {
    local version_suffix="$1"
    cd $DIR/../
    $DIR/../scripts/update-reqs.sh
    $DIR/../scripts/gather-deps.sh
    local version="$(cat Chart.yaml | grep 'version:' | awk '{print $2}')"
    helm push . --version="${version}${version_suffix}" codefresh
}

function main {
    local version_suffix=""

    local git_branch="${GIT_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"
    if [[ "$git_branch" == "master" ]]; then
        echo "[release-all] Git branch is \"master\", releasing charts without version suffix"
    else
        version_suffix="-$git_branch"
        echo "[release-all] Git branch is \"$git_branch\", releasing charts with suffix \"$version_suffix\""
    fi

    release_common_simplepod $version_suffix
    release_app1 $version_suffix
    release_app2 $version_suffix
    release_app3 $version_suffix
    release_self $version_suffix
}

main "$@"
