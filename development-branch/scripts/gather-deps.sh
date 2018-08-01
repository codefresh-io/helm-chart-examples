#!/bin/bash -e

rm -f requirements.lock
rm -rf charts/
helm dep up
