#!/bin/bash

# gifoverlay.sh: a tool to overlay pictures on top of a possibly tiling gif (TODO)

TILE=0

while [ "$#" -gt "0" ]; do
	case $1 in
		-h | --help)
			echo "- gifoverlay.sh -"
			echo "A tool for overlaying stuff in gifs"
			echo "usage: gifoverlay.sh [options] [gif to use as template] [image to overlay]"
			echo "Options available:"
			echo "-h , --help : lists this help"
			echo "-t , --tile : tile the gif to fit the picture (TODO!)"
		;;
		
		-t | --tile)
			TILE=1
		;;

		*) #done reading options, assume the rest are file names.
			#inFile="$1"
			#fileExt="${1#*.}"
			#destFile="${1%.*}"
			#monogif="${destFile}_mono.${fileExt}"
			#finally convert file to grayscale
			#convert ${1} -modulate 100,0,100 ${monogif}
			
			#just get start frame
			#gifsize=`identify -ping -format '%w %h' ${1}[0]` 
			gifwidth=`identify -ping -format '%w' ${1}[0]`
			gifheight=`identify -ping -format '%h' ${1}[0]`
			let gifarea=`identify -ping -format '%w*%h' ${1}[0]`
			
			#imgsize=`identify -ping -format '%w %h' ${2}`
			imgwidth=`identify -ping -format '%w' ${2}`
			imgheight=`identify -ping -format '%h' ${2}`
			let imgarea=`identify -ping -format '%w*%h' ${2}`
			
			if [ ${gifarea} -gt ${imgarea} ]; then
				convert \( \( ${1} -modulate 100,0,100 -coalesce \) -filter lanczos -resize ${imgwidth}x${imgheight}^ -crop ${imgwidth}x${imgwidth}+0+0 +repage -coalesce \) null: ${2} -compose Overlay -layers composite -layers optimize output.gif
			fi

			if [ ${gifarea} -lt ${imgarea} ]; then
				convert \( \( \( ${1} -modulate 100,0,100 -coalesce \) -filter point -resize ${imgwidth}x${imgheight}^ +repage \) -crop ${imgwidth}x${imgwidth}+0+0 +repage -coalesce \) null: ${2} -compose Overlay -layers composite -layers optimize output.gif
				
			fi
			
			if [ ${gifarea} -eq ${imgarea} ]; then
			convert \( ${1} -modulate 100,0,100 -coalesce \) null: ${2} -compose Overlay -layers composite -layers optimize output.gif
				
			fi

			break
		;;
	esac
	shift
done
