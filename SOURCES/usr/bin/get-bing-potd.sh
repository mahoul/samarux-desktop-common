#!/bin/bash

die(){
	echo -e $1
	# Remove temp file and quit.
	#
	[ -f $BING_XML ] && rm -f $BING_XML
	exit $2
}

curl_call(){
	local url=$1
	timeout 1s curl -sL $url
}

get_bing_wp_xml(){
	curl_call $BING_URL > $BING_XML
}

get_ep(){
	local ep=$1
	echo "whereis //$ep" | xmllint --shell $BING_XML | head -1 | awk '{print $NF}'
}

get_ep_value(){
	local ep=$1
	xmllint --xpath "$1/text()" $BING_XML 2>/dev/null
}

get_img_url(){
	get_ep_value $(get_ep url)
}

get_img_date(){
	get_ep_value $(get_ep startdate)
}

get_img_copyright(){
	get_ep_value $(get_ep copyright)
}

get_bing_img_filename(){
	date "+$BING_IMG_DIR/bing_wp_%Y_%m_%d.png"
}

get_img_file(){
	local url=$1
	local comment=$2
	local img_file=$3

	echo -e "Downloading POTD: $img_file : $comment ..."

	if [ $EMBED_IMG_INFO -eq 1 ]; then
		curl_call "http://www.bing.com/$url" | \
convert -comment "$comment" -font helvetica -fill white -pointsize 14 \
-gravity southwest -draw "text 0,0 '$comment'" \
- $img_file
	else
		curl_call "http://www.bing.com/$url" | \
convert -comment "$comment" \
- $img_file
	fi
}

use(){
	die "${0} [ -e ]\n\t-e: Embed copyright info into the image (default: no)" 0
}

if [ "$#" -gt 1 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
	use
fi

BING_XML=$(mktemp)

BING_URL='http://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=1&mkt=en-US'
BING_IMG_DIR="/usr/share/wallpapers/bing"
BING_IMG=$(get_bing_img_filename)
BING_IMG_TODAY="$BING_IMG_DIR/today.png"
DEFAULT_WALLPAPER="/usr/share/backgrounds/default.png"
EMBED_IMG_INFO=0

# If -e is passed as arg, embed description on the lower left corner.
#
if [ "$1" == "-e" ]; then
	EMBED_IMG_INFO=1
fi

# Try to create the system wide storage directory.
#
if [ ! -d $BING_IMG_DIR ]; then
	mkdir -p $BING_IMG_DIR || die "Could not create dir $BING_IMG_DIR. Please check permissions." 5
fi

# Fail if we couldn't create the temp file.
# 
if [ ! -f $BING_XML ]; then
	die "Could not create temp file. Quitting." 3
fi

# Download the Picture Of The Day if not already downloaded,
# quit if it's already present.
#
if [ ! -s $BING_IMG ]; then
	echo -e "Getting Bing Picture of The Day xml file ..."
	get_bing_wp_xml

	BING_IMG_URL=$(get_img_url)
	if [ -z "$BING_IMG_URL" ]; then
		die "Failed to get xml info. Quitting" 1
	fi

	BING_IMG_COMMENT=$(get_img_copyright)

	get_img_file "$BING_IMG_URL" "$BING_IMG_COMMENT" "$BING_IMG"
fi

# Symlink the POTD as today.png.
#
if [ -s $BING_IMG ]; then
       ln -sf $BING_IMG $BING_IMG_TODAY
       ln -sf $BING_IMG $DEFAULT_WALLPAPER
fi

die "" 0

