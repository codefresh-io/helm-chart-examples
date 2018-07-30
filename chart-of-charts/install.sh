#!/bin/bash -ex

for d in $(find charts/ -type d -mindepth 1 -maxdepth 1); do
    (cd $d && helm dep up)
done

helm upgrade --install myrelease . -f ./override-values.yaml

