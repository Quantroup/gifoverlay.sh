#!/bin/bash

# gifoverlay.sh: a tool to overlay pictures on top of a possibly tiling gif (TODO)

TILE=0
mask="none"

while [ "$#" -gt "0" ]; do
	case $1 in
		-h | --help)
			echo "- gifoverlay.sh -"
			echo "A tool for overlaying stuff in gifs"
			echo "usage: gifoverlay.sh [options] [gif to use as template] [image to overlay]"
			echo "Options available:"
			echo "-h , --help : lists this help"
			echo "-t , --tile : tile the gif to fit the picture (TODO!)"
			echo "-m=foo , --mask=foo : use the file foo for a mask (this copies the alpha channel of the template)"
		;;
		
		-t | --tile)
			TILE=1
		;;

		-m=* | --mask=* )
			mask="`echo ${1} | cut -d '=' -f 2`"
			echo "Mask file: ${mask}"
			
		;;

		*) #done reading options, assume the rest are file names.
			
			#just get start frame
			#gifsize=`identify -ping -format '%w %h' ${1}[0]` 
			#gifwidth=`identify -ping -format '%w' ${1}[0]`
			#gifheight=`identify -ping -format '%h' ${1}[0]`
			let gifarea=`identify -format '%w*%h' ${1}[0]`
			
			#imgsize=`identify -ping -format '%w %h' ${2}`
			imgwidth=`identify -format '%w' ${2}`
			imgheight=`identify -format '%h' ${2}`
			let imgarea=`identify -format '%w*%h' ${2}`
			
			if [ ${gifarea} -gt ${imgarea} ]; then
				filter="lanczos"
			else
				filter="point"
			fi
			
			if [ ${mask} != "none" ]; then
				
				let maskarea=`identify -ping -format '%w*%h' ${mask}`
				maskwidth=`magick identify -format '%w' ${mask}[${imgwidth}x${imgheight}]`
				maskheight=`magick identify -format '%h' ${mask}[${imgwidth}x${imgheight}]`
				let maskoffset="( ${imgwidth} / 2 ) - ( ${maskwidth} / 2 )"
				#echo "mask width: ${maskwidth}"
				#echo "mask offset: ${maskoffset}"

				if [ ${maskarea} -gt ${imgarea} ]; then
					maskfilter="lanczos"
				else
					maskfilter="point"
				fi


				if [ ${imgarea} -eq ${maskarea} ]; then
					convert \( \( ${1} -modulate 100,0,100 -coalesce \) null: ${2} -gravity west -compose Overlay -layers composite \) -coalesce null: ${mask} -gravity center -compose CopyOpacity -layers composite output.gif
				else
					convert \( \( \( ${1} -modulate 100,0,100 -coalesce \) -gravity west -filter ${filter} -resize ${imgwidth}x${imgheight}^ -crop ${imgwidth}x${imgheight}+0+0 +repage -coalesce \) null: ${2} -compose Overlay -layers composite \) null: \( ${mask} -filter ${maskfilter} -resize ${imgwidth}x${imgheight} +repage -coalesce \) -gravity center -compose CopyOpacity -layers composite -coalesce output.gif
					mogrify -gravity west -coalesce -crop ${maskwidth}x${maskheight}+${maskoffset}+0 output.gif
				fi
				
			else
				if [ ${gifarea} -eq ${imgarea} ]; then
					convert \( ${1} -modulate 100,0,100 -coalesce \) null: ${2} -gravity west -compose Overlay -layers composite -layers optimize output.gif
				
				else
					convert \( \( ${1} -modulate 100,0,100 -coalesce \) -filter ${filter} -resize ${imgwidth}x${imgheight}^ -crop ${imgwidth}x${imgheight}+0+0 +repage -coalesce \) null: ${2} -gravity west -compose Overlay -layers composite -layers optimize output.gif
				
				
				fi
			fi

			break
		;;
	esac
	shift
done
