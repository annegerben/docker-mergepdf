#!/bin/bash
INPUT=/srv/input
OUTPUT=/srv/output

cd $INPUT

if [[ $1 != *.pdf ]]; then
  echo "not a pdf file, do nothing"
  exit
fi

if [[  "$1" == *_merged.pdf ]]; then
  echo "self created pdf, do nothing"
  exit
fi

if [[  "$1" != *_o.pdf && "$1" != *_e.pdf  ]]; then
  #no multipage pdf file, copy directly to Output folder
  echo "$(date +%F-%T) detected non mutlipage file"
  inotifywait -e close $1
  sleep 1
  mv --backup=t $1 $1\_$(date +%F-%T)
  echo "moved to $1_$(date +%F-%T)"
  exit
fi

if [[ "$1" == *_o.pdf ]]; then
  echo "$(date +%F-%T) odd file detected"
  stringOdd=$(basename "$1")
  stringEven=${1/%_o.pdf/_e.pdf}
else
  #even file created first for some reason
  echo "$(date +%F-%T) even file detected"
  stringOdd=${1/%_e.pdf/_o.pdf}
  stringEven=$(basename "$1")
fi

stringMerged=${stringOdd/%_o.pdf/_merged.pdf}
  echo "merged string $stringMerged"

if [[ -f $stringOdd && -f $stringEven ]]; then
  inotifywait -e close $stringOdd $stringEven
  sleep 1
  echo "executing pdftk"
  pdftk A=$stringOdd B=$stringEven shuffle A Bend-1 output $stringMerged
  if [[ $RET -eq 0 ]]; then
    echo "pdftk was successful, removing temporary files..."
    rm  -f $stringOdd $stringEven
  fi

  sleep 1
  mv $stringMerged $stringMerged\_$(date +%F-%T)
  sleep 2
  echo "done..."
  exit
fi
