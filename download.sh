#!/bin/bash
if [ -z $1 ]; then echo "link is unset"; exit; fi
if [ -z $2 ]; then echo "outfile is unset"; exit; fi
in=$1
out=$2
echo $in
r=$(curl $in -s | egrep -o '/redirect/[0-9]+' | head -n 1)
echo $r
if [ -z $r ]; then echo "episode not found, exiting"; exit; fi
link=$(curl -L -s https://s.to/$r | egrep -o  "hls'.*'" | tail -c+8 | tr -d "'")
echo $link
echo ffmpeg -user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36" -i $link -c copy $out
ffmpeg -user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36" -i $link -c copy -y $out


