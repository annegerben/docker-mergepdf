#!/bin/bash
INPUT=/srv/input
OUTPUT=/srv/output

cd $INPUT

if [[ $1 != *.pdf ]]; then
  #not a pdf file, do nothing
  exit
fi

if [[  "$1" != *_o.pdf && "$1" != *_e.pdf  ]]; then
  #no multipage pdf file, move directly to Output folder
  TMP=0
  until [ $TMP -eq $(stat -c %s $1) ]
  do
    TMP=$(stat -c %s $1)
    sleep 5
  done
  sleep 25
  mv $1 $OUTPUT
  exit
fi

if [[ "$1" == *_o.pdf ]]; then
  stringOdd=$(basename "$1")
  stringEven=${1/%_o.pdf/_e.pdf}
else
  #even file created first for some reason
  stringOdd=${1/%_e.pdf/_o.pdf}
  stringEven=$(basename "$1")
fi

stringMerged=${stringOdd/%_o.pdf/_merged.pdf}

if [[ -f $stringOdd && -f $stringEven ]]; then
  sleep 15
  pdftk A=$stringOdd B=$stringEven shuffle A Bend-1 output $OUTPUT/$stringMerged
  rm  -f $stringOdd $stringEven
  sleep 2 #needed when copying multiple files into the Input folder
  exit
fi

