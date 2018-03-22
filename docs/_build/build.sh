#!/bin/bash

# Run typesetting script
R -f _build/typeset_transcriptions.R

bundle exec jekyll build
