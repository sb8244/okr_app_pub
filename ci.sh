#!/usr/bin/env bash

./codeship.wait.sh &&
MIX_ENV=test mix test
