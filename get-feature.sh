#!/bin/bash
export FEATURE=$(echo $(cd ../sproud-$1 && git symbolic-ref HEAD) | cut -c 12- | cut -d '-' -f 1 | cut -d '/' -f 2)
