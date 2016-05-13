#!/bin/bash

if [ "$1" == "" -o "$2" == "" ]; then
  echo "download.sh OutputFilename URL [Speed]"
  exit -1
fi

SPEED=
if [ "$3" != "" ]; then
  SPEED="--limit-rate $3"
else
  SPEED="--limit-rate 50k"
fi

I=1
FULLSIZE=$(curl -I "$2" | grep "Content-Length" | cut -d' ' -f2)
RESULT=$(curl $SPEED --output "$1-$I" "$2")
while [ "$RESULT" != "0" ]; do
  echo "retry..."
  sleep 5
  PING=$(ping -c 1 8.8.8.8 | grep "64 bytes" | wc -l | tr -s ' ' ' ' | cut -d' ' -f2)
  while [ "$PING" != "1" ]; do
    echo "waiting for connectivity..."
    PING=$(ping -c 1 8.8.8.8 | grep "64 bytes" | wc -l | tr -s ' ' ' ' | cut -d' ' -f2)
  done
  cat "$1-$I" >> "$1-TEMP"
  rm "$1-$I"
  SIZE=$(ls -la | grep "$1-TEMP" | tr -s ' ' ' ' | cut -d' ' -f5)
  echo "SIZE: $SIZE"
  echo "FULLSIZE: $FULLSIZE"
  if [ $SIZE -lt $FULLSIZE ]; then
    I=$(($I + 1))
    RESULT=$(curl -C $SIZE $SPEED --output "$1-$I" "$2")
  else
    RESULT=0
  fi
done
cat "$1-$I" >> "$1-TEMP"
rm "$1-$I"
rm $1
mv "$1-TEMP" $1

echo "done."
