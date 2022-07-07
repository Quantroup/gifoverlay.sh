#!/bin/bash

# gifoverlay.sh: a tool to overlay pictures on top of a possibly tiling gif (TODO)

tile=0
optimize=0
filename="output.gif"
mask="none"

while [ "$#" -gt "0" ]; do
	case $1 in
		-h | --help)
			echo "- gifoverlay.sh -"
			echo "A tool for overlaying stuff in gifs"
			echo "usage: gifoverlay.sh [options] [gif to use as template] [image to overlay]"
			echo "Options available:"
			echo "-h , --help : lists this help"
			echo "-t , --tile : tile the gif to fill (aka make sure the gif covers the entire thing) the image then crop to image"
			echo "-m=foo , --mask=foo : use the file foo for a mask (this copies the alpha channel of the template) (thanks to @piconaut for help!)"
			echo "-o , --optimize : optimize the gif layers."
			echo "-f=bar , --file=bar : save to the file named bar"
		;;
		
		-t | --tile)
			tile=1
		;;

		-m=* | --mask=* )
			mask="`echo ${1} | cut -d '=' -f 2`"
			echo "Mask file: ${mask}"
			
		;;

		-o | --optimize )
			optimize=1
		;;

		-f=* | --file=* )
			filename="`echo ${1} | cut -d '=' -f 2`"
			echo "Filename to save as: ${filename}"
		;;

		*) #done reading options, assume the rest are file names.
			
			#just get start frame
			gifsize=`identify -ping -format '%w%h' ${1}[0]` 
			gifwidth=`identify -ping -format '%w' ${1}[0]`
			gifheight=`identify -ping -format '%h' ${1}[0]`
			let gifarea=`identify -format '%w*%h' ${1}[0]`
			
			imgsize=`identify -ping -format '%w%h' ${2}`
			imgwidth=`identify -format '%w' ${2}`
			imgheight=`identify -format '%h' ${2}`
			let imgarea=`identify -format '%w*%h' ${2}`
			
			if [ ${gifarea} -gt ${imgarea} ]; then
				filter="lanczos"
			else
				filter="point"
			fi
			
			if [ ${mask} != "none" ]; then
				
				masksize=`identify -ping -format '%w%h' ${mask}`
				let maskarea=`identify -ping -format '%w*%h' ${mask}`
				maskwidth=`magick identify -format '%w' ${mask}[${imgwidth}x${imgheight}]`
				maskheight=`magick identify -format '%h' ${mask}[${imgwidth}x${imgheight}]`
				let maskoffset="( ${imgwidth} / 2 ) - ( ${maskwidth} / 2 )"
				#echo "mask width: ${maskwidth}"
				#echo "mask offset: ${maskoffset}"

				if [ ${masksize} -gt ${imgsize} ]; then
					maskfilter="lanczos"
				else
					maskfilter="point"
				fi
			fi
			
			# b&w gif
			magick ${1} -modulate 100,0,100 -coalesce tempout.gif
			
			# handle size difference between gif and img (and tiling)
			if [ ${tile} -eq 1 ]; then
				echo "+++++++ TODO! sorry... but we must end the program here (or it will fail horribly) +++++++"
				exit 1
			elif [ ${gifsize} -eq ${imgsize} ]; then
				: #do nothing.
			else
				magick mogrify -gravity west -filter ${filter} -resize ${imgwidth}x${imgheight}^ -crop ${imgwidth}x${imgheight}+0+0 +repage -coalesce tempout.gif
			fi

			# overlay image ontop of the gif
			magick tempout.gif  null: ${2} -gravity west -compose Overlay -layers composite tempout.gif

			# process mask
			if [ ${mask} = "none" ]; then
				: #nothing. wait for optimize
			else
				if [ ${imgsize} -eq ${masksize} ]; then
					magick tempout.gif -coalesce null: ${mask} -gravity center -compose CopyOpacity -layers tempout.gif
				else
					magick tempout.gif -coalesce null: \( ${mask} -filter ${maskfilter} -resize ${imgwidth}x${imgheight} +repage -coalesce \) -gravity center -compose CopyOpacity -layers composite -coalesce tempout.gif
					mogrify tempout.gif -gravity west -coalesce -crop ${maskwidth}x${maskheight}+${maskoffset}+0 tempout.gif
				fi
			fi
			
			if [ ${optimize} -eq 1 ]; then
				magick tempout.gif -layers optimize ${filename}
			else
				mv tempout.gif ${filename}
			fi

			break
		;;
	esac
	shift
done
