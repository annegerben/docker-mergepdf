#!/bin/bash
INPUT=/srv/input
OUTPUT=/srv/output
DATE=$(date +%F-%T): 
DEBUG="echo $DATE start script with $1"
FILENAME=$(date +%Y%m%d_%H%M%S)
stringOdd=scan_o.pdf
stringEven=scan_e.pdf

$DEBUG

cd $INPUT

if [[ "$1" != *.pdf ]]; then
  echo "$DATE not a pdf file, exit"
  
  exit
fi

if [[ "$1" == *_merged.pdf ]]; then
  echo "$DATE self created pdf, exit"
  exit
fi

if [[  "$1" != *_o.pdf && "$1" != *_e.pdf  ]]; then
  echo "$DATE not odd or even, exit"
  exit
fi

if [[ -f $stringOdd && -f $stringEven ]]; then
  #inotifywait -e close $stringOdd $stringEven
  sleep 5
  echo "$DATE executing pdftk"
  pdftk A=$stringOdd B=$stringEven shuffle A Bend-1 output $OUTPUT/$FILENAME.pdf
  
  if [[ $RET -eq 0 ]]; then
    echo "$DATE pdftk merge was successful $FILENAME.pdf created, removing temporary $stringOdd $stringEven files..."
    rm  -f $stringOdd $stringEven
  fi

  echo "$DATE done..."
  exit
 else
  echo "$DATE file missing, exit" 
  
fi
