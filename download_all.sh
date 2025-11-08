#!/bin/bash
if [ -z $1 ]; then echo "No name provided"; echo "usage: sto name [season_number [episode_number]]"; exit 2; fi

in=$1

dir="/app/$1"
mkdir -p $dir
st="staffel-1"


staffeln=$(curl -s "https://s.to/serie/stream/$1" | egrep -o "staffel\-[0-9]+\"" | sort -u | natsort | tr -d '"')

for st in $staffeln; do 
    echo $st; 
    if [ "$2" ]; then
        if [[ "$st" == "staffel-$2" ]]; 
            then echo "Entering selected $st";
            else echo "skip"; continue; 
        fi
    fi

    staffel=`printf 'staffel_%02g' $(echo $st | cut -f2 -d'-')`

    mkdir -p "$dir/$staffel"
    episoden=$(curl -s "https://s.to/serie/stream/$1/$st" | egrep -o 'episode-[0-9]+?\"' | sort -u | natsort | tr -d '"');
    for e in $episoden; do
        if [ $3 ]; then
            if [[ "$e" == "episode-$3" ]]; 
                then echo "Downloading $st $e";
                else echo "Skipping $e"; continue; 
            fi
        fi


        name=`printf 'episode_%02g.mkv' $(echo $e | cut -f2 -d'-')`
        echo python download.py "https://s.to/serie/stream/$1/$st/$e" "$dir/$1/$staffel/$name"
        python download.py "https://s.to/serie/stream/$1/$st/$e" "$dir/$staffel/$name"
    done
done


