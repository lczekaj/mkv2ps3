#!/bin/bash
# Script converting mkv files to mp4 files compatible with Sony Playstation 3
# Coded by Lukasz Czekaj <lukasz[at]czekaj.us>
# Based on code by Werner Gillmer <werner.gillmer@gmail.com>

# Usage : mkv2ps3.sh movie.mkv
#         mkv2ps3.sh movie.mkv /Volumes/ExtHDD/Video/
#         mkv2ps3.sh /path/to/dir/with/mkv/files 
#         mkv2ps3.sh /path/to/dir/with/mkv/files /Volumes/ExtHDD/Video/
#         mkv2ps3.sh .
#         mkv2ps3.sh . /Volumes/ExtHDD/Video

# The main purpose of this fork is to do the final mp4 file generation at destination directory (e.g. /Volumes/ExtHDD/Video/). It is useful and time-saving if you tend to copy your mp4 file to an external storage like USB stick or external HDD. It is done for you while saving the file.
#
# Warning: if directory input is used all mkv files will be renamed by replacing spaces with underscores (_)
#
# Tested on Mac OS X Lion (10.7.3). The mp4 files can appear broken on a Mac but they play fine on PS3. It's because of replacing mp4box completely with ffmpeg for speed sake.
# I use homebrew (https://github.com/mxcl/homebrew/) to install dependencies such as mkvtoolnix and ffmpeg.

function cleanup {
    echo -n "### Cleaning up... "
    # to delete original file after conversion just uncomment the line below
    # rm $1
    rm *mkv.dts
    rm *mkv.aac
    rm *mkv.264

    echo -n "Renaming to mp4... "
    NEWNAME=`ls $1 | sed 's/mkv.mp4/mp4/'`
    mv $1 $NEWNAME
	
    echo "done"
}

function mkv2ps3 {
    mkvextract tracks $1 1:$1.h264 2:$1.ac3

    # Makes the audio stream a pure aac
    ffmpeg -i $1.dts -vcodec libfaac $1.aac

    # Merge everything to mp4
    OUT_FILE=$1.mp4
    if [ "$OUT_DIR" ] && [ -d $OUT_DIR ]; then
        OUT_DIR=${OUT_DIR%/}
        OUT_FILE="${OUT_FILE##*/}"
        echo -e "### Creating $OUT_FILE at $OUT_DIR\r"
        OUT_FILE="$OUT_DIR/$OUT_FILE"
	fi
    ffmpeg -fflags genpts -f h264 -i $1.h264 -f ac3 -i $1.ac3 -vcodec copy -acodec copy -copyts -f mp4 -y $OUT_FILE

    cleanup $OUT_FILE 
}

IN_FILE=$1
OUT_FILE="${IN_FILE##*/}"      # Strip longest match of */ from start
OUT_DIR=$2
if  [ "$2" ] && [ -d "$2" ]; then
    echo -e "### Output will be created in $OUT_DIR\r"
fi
if [ -d $1 ]; then
    IN_DIR=$1
    echo -e "### Input is a directory. Using *.mkv in $IN_DIR\r"
    cd $IN_DIR

    # Replace all white spaces with a _ 
    #IFS=$'\n'
    for f in *.mkv; do
        file=$(echo $f | sed 's/ /_/g')
        if [ "$f" != $file ]; then
            echo -e "### Moving file $f\r"
            mv "$f" $file
        fi
    done
    #unset IFS

    for IN_FILE in *.mkv;
        do
            IN_DIR=${IN_DIR%/}            
            mkv2ps3 "$IN_DIR/$IN_FILE"
    done
else
    if [ -f "$1" ]; then 
        # Replace white spaces in file name with a _
        IN_FILE=$(echo "$1" | sed 's/ /_/g')
        mv "$1" $IN_FILE  
        mkv2ps3 $IN_FILE
    else
        echo "### ERROR: Cannot find $new_file"
        exit
    fi
    unset IN_DIR
fi

unset IN_FILE
unset OUT_DIR
unset OUT_FILE
