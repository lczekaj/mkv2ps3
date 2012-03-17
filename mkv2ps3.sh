#!/bin/bash
# Script to convert mkv files to PS3 playable mp4
# Coded by Werner Gillmer <werner.gillmer@gmail.com>
# following psilo357 advice from https://bbs.archlinux.org/viewtopic.php?id=62298&p=2
# Extended by Lukasz Czekaj <lukasz[at]czekaj.us>

# Usage : mkv2ps3.sh movie.mkv
#         mkv2ps3.sh /path/to/dir/with/mkv/files 
# or	: mkv2ps3.sh movie.mkv /output_dir/

# MP4Box http://gpac.wp.institut-telecom.fr/mp4box/
# mkvtoolnix http://www.bunkus.org/videotools/mkvtoolnix/
# ffmpeg http://www.ffmpeg.org/

# Tested on Linux (Arch) and OS X(Lion)

OUTPUT_DIR=$2

function cleanup {
    echo -n "### Cleaning up..."
    # to delete original file after conversion just uncomment the line below
    # rm $1
    rm *mkv.dts
    rm *mkv.aac
    rm *mkv.264

	if  [ -d $OUTPUT_DIR ]; then
	    NEWNAME=`ls $OUTPUT_DIR$1.mp4 | sed 's/mkv.mp4/mp4/'`
	    mv $OUTPUT_DIR$1.mp4 $NEWNAME
	else
	    NEWNAME=`ls $1.mp4 | sed 's/mkv.mp4/mp4/'`
	    mv $1.mp4 $NEWNAME
	fi
	
    echo "done"
}


function mkv2ps3 {
    # Extracts the video stream
    mkvextract tracks "$1" 1:$1.264
    # Extracts the audio stream
    mkvextract tracks "$1" 2:$1.dts

    # Makes the audio stream a pure aac
    ffmpeg -i $1.dts -vcodec libfaac $1.aac

    # Merge everything to mp4
	if [ -d $OUTPUT_DIR ]; then
		    echo -e "### Creating .mp4 at $OUTPUT_DIR$1\r"
	    MP4Box -new $OUTPUT_DIR$1.mp4 -add $1.264 -add $1.aac -fps 23.976
	else
	    MP4Box -new $1.mp4 -add $1.264 -add $1.aac -fps 23.976
	fi

    cleanup $1 
}

echo -e "Output will be copied to: $OUTPUT_DIR\r"

if [ -d $1 ]; then
    DIR=$1
    cd $DIR

    # Replace all white spaces with a _ 
    #IFS=$'\n'
    for f in `find .`; do
        file=$(echo $f | tr [:blank:] '_')
        mv "$f" $file
    done
    #unset IFS

    for mkv_file in *.mkv;
        do
            mkv2ps3 $mkv_file
    done
    else
        if [ -f "$1" ]; then 
            # Replace white spaces in file name with a _
            new_file=$(echo "$1" | tr [:blank:] '_')
            mv "$1" $new_file  

            mkv2ps3 $new_file
            else
                echo "ERROR: Cannot find $new_file"
                exit
        fi
   unset DIR
fi 
     


