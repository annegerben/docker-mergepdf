#!/bin/bash

if [[  $1 == *_merged.pdf || $1 == *_o.pdf || $1 == *_e.pdf || $1 == merge*.pdf  ]]; then
  exit
fi

cd /srv/even

if [[ $1 == *.pdf ]]; then
  sleep 5
  mv $1 /srv/input/"even_"$1
  exit
fi
