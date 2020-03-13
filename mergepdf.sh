#!/bin/bash
INPUT=/srv/input
OUTPUT=/srv/output
stringOdd="merge_o.pdf"
stringEven="merge_e.pdf"

cd $INPUT

if [[  $1 == *_merged.pdf || $1 == *_o.pdf || $1 == *_e.pdf  ]]; then
  exit
fi

if [[ $1 == *.jpg || $1 == *.tiff ]]; then
  echo "got a picture, copy direct to output"
  inotifywait -t FW_TIMEOUT -e close $1
  mv $1 $OUTPUT/"$(date +%Y-%m-%d_%H-%M-%S)_"$1
  echo "done..."
  exit
fi

if [[ $1 != *.pdf ]]; then
  echo "not a pdf file, do nothing"
  exit
fi

if [[  "$1" != odd*.pdf && "$1" != even*.pdf  ]]; then
  #no multipage pdf file, copy directly to Output folder
  echo "$(date +%Y-%m-%d_%H-%M-%S) - detected non mutlipage file"
  inotifywait -t FW_TIMEOUT -e close $1
  sleep 3
  rm $1
  echo "$(date +%Y-%m-%d_%H-%M-%S) OCR done!"
  sleep 2
  exit
fi

if [[ "$1" == odd*.pdf ]]; then
  echo "$(date +%Y-%m-%d_%H-%M-%S) - odd file detected"
  mv -f $1 $stringOdd
else
  echo "$(date +%Y-%m-%d_%H-%M-%S) - even file detected"
  mv -f $1 $stringEven
fi

if [[ -f $stringOdd && -f $stringEven ]]; then
  stringMerged="$(date +%Y-%m-%d_%H-%M-%S)_merged.pdf"
  inotifywait -t FW_TIMEOUT -e close $stringOdd $stringEven
  sleep 1
  echo "executing pdftk"
  pdftk A=$stringOdd B=$stringEven shuffle A Bend-1 output $stringMerged
  if [[ $RET -eq 0 ]]; then
    echo "pdftk was successful, removing temporary files..."
    echo "merged file: $stringMerged"
    rm  -f $stringOdd $stringEven
  fi
  rm $stringMerged
  sleep 1
  echo "done..."
  exit
fi
echo "done..."
