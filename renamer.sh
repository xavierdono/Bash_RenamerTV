#!/bin/bash

urlshow="https://api.tvmaze.com/singlesearch/shows?q="

filename=$1

fname=$(basename $filename)
dirname=$(dirname $filename)
fbname=${fname%.*}
fbnameupper=${fbname^^}
showname=${fbnameupper%.S*}
showext=${fname##*.}

show_id=$(curl -s $urlshow${showname/./ } | jq -r '.id')

if [ "$show_id" == "" ]; then
	zenity --info --text="Série non trouvée"
else
    if [[ "$filename" =~(\**).*(.*[0-9][0-9]).*([0-9][0-9]).*(\....)$ ]]; then
        show_season=${BASH_REMATCH[2]}
        show_episode=${BASH_REMATCH[3]}
    fi

    urlFullName="https://api.tvmaze.com/shows/$show_id/episodebynumber?season=$show_season&number=$show_episode"

    name=$(curl -s $urlFullName | jq -r '.name')

    if [ "$name" == "Not Found" ]; then
	    zenity --info --text="Episode non trouvé"
    else
        show=${showname/./ }
        finalshow=(${show,,})

        realnameshow="${finalshow[@]^} - ${show_season}x${show_episode} - ${name/:/ }.$showext"

        mv "$filename" "$dirname/$realnameshow"
    fi
fi
