#!/bin/bash -e

function get_all_deps {
    ruby -ryaml -e \
        "YAML.load_file('requirements.yaml')['dependencies'].each do|e|;puts e['name'];end"
}

function get_dep_repo {
    local dep="$1"
    ruby -ryaml -e \
        "YAML.load_file('requirements.yaml')['dependencies'].each do|e|;if e['name']=='$dep';puts e['repository'];end;end"
}

function get_dep_version {
    local dep="$1"
    ruby -ryaml -e \
        "YAML.load_file('requirements.yaml')['dependencies'].each do|e|;if e['name']=='$dep';puts e['version'];end;end"
}

function update_dep_version {
    local dep="$1"
    local new_version="$2"
    ruby -ryaml -e \
        "d=YAML.load_file('requirements.yaml');d['dependencies'].each do|e|;if e['name']=='$dep';e['version']='$new_version';end;end;File.open('requirements.yaml','w'){|f|YAML.dump(d,f)}"
}

function main {
    [[ ! -f requirements.yaml.bak ]] || mv requirements.yaml.bak requirements.yaml

    if [[ ! -f requirements.yaml ]]; then
        echo "[update-reqs] No requirements.yaml, nothing to do"
        exit 0
    fi

    local git_branch="${GIT_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"
    if [[ "$git_branch" == "master" ]]; then
        echo "[update-reqs] Git branch is \"master\", nothing to do"
        exit 0
    fi

    command -v ruby &> /dev/null || ( echo "ruby is (unfortunately) required for the rest of this script." && exit 1 )

    echo "[update-reqs] Git branch is \"$git_branch\", searching for dep versions with suffix \"-$git_branch\""
    cp requirements.yaml requirements.yaml.bak

    echo "[update-reqs] Updating all helm repos"
    helm repo update

    for dep in $(get_all_deps); do
        local repo="$(get_dep_repo $dep)"
        if [[ "$repo" =~ ^\@ ]]; then # repo references must begin w @ symbol
            repo="${repo:1}" # remove @ symbol
            local version="$(get_dep_version $dep)"
            local new_version="$version-$git_branch"
            # check if the chart repo contains a version matching $newversion
            if helm search "$repo/$dep" -l | tail -n +2 | awk '{print $2}' | grep "^$new_version$" &> /dev/null; then
                echo "[update-reqs] Found version \"$new_version\" of the \"$dep\" chart, updating in requirements.yaml"
                update_dep_version $dep $new_version
            fi
        fi
    done
}

main "$@"
