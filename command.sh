#!/bin/bash
echo "Welcome to RapiPub"
echo "Checking for Videos to Process"
MEDIAPATH=$1
OUTPUTDIR=$2
INTRO=$3
OUTRO=$4
RESOLUTION=$5
CODEC=$6
RATELIMIT=$7
NOUPLOAD=$8
find "$MEDIAPATH" -type f \( -iname \*.m4v -o -iname \*.mp4 -o -iname \*.mov  -o -iname \*.webm \) -print0 |
    while IFS= read -r -d '' video; do
        echo "Found video at: $video"
        output="$OUTPUTDIR/$(basename -- "$video").mp4"
        if [[ -f "$output" ]]; then
            echo "Video Already Converted"
        elif [[ -f "$OUTRO"  ]] && [[ -f "$INTRO"  ]]; then
            echo "Merging Video with Intro and Outro"
            ffmpeg -y \
                -hide_banner \
                -loglevel error \
                -nostdin  \
                -fflags +genpts \
                -i "$INTRO" \
                -i "$video" \
                -i "$OUTRO" \
                -c:v $CODEC \
                -x265-params log-level=error \
                -crf 17 \
                -r 60 \
                -c:a aac \
                -b:a 192k \
                -tag:v hvc1 \
                -movflags +faststart \
                -preset medium \
                -level 3.0 \
                -filter_complex "\
                [0:v]scale=$RESOLUTION:flags=lanczos,zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p[v0]; \
                [1:v]scale=$RESOLUTION:flags=lanczos,zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p[v1]; \
                [2:v]scale=$RESOLUTION:flags=lanczos,zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p[v2]; \
                [v0][0:a][v1][1:a][v2][2:a]concat=n=3:v=1:a=1[v][a]"\
                -map "[v]" -map "[a]" \
                "$output"
        elif [[ -f "$INTRO" ]]; then
            echo "Merging Video with Intro or Outro"
            ffmpeg -y \
                -hide_banner \
                -loglevel error \
                -nostdin  \
                -fflags +genpts \
                -i "$INTRO" \
                -i "$video" \
                -c:v $CODEC \
                -x265-params log-level=error \
                -crf 17 \
                -r 60 \
                -c:a aac \
                -b:a 192k \
                -tag:v hvc1 \
                -movflags +faststart \
                -preset medium \
                -level 3.0 \
                -filter_complex "\
                [0:v]scale=$RESOLUTION:flags=lanczos,zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p[v0]; \
                [1:v]scale=$RESOLUTION:flags=lanczos,zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p[v1]; \
                [v0][0:a][v1][1:a]concat=n=3:v=1:a=1[v][a]"\
                -map "[v]" -map "[a]" \
                "$output"
        elif [[ -f "$OUTRO" ]]; then
            echo "Merging Video with Intro or Outro"
            ffmpeg -y \
                -hide_banner \
                -loglevel error \
                -nostdin  \
                -fflags +genpts \
                -i "$video" \
                -i "$OUTRO" \
                -c:v $CODEC \
                -x265-params log-level=error \
                -crf 17 \
                -r 60 \
                -c:a aac \
                -b:a 192k \
                -tag:v hvc1 \
                -movflags +faststart \
                -preset medium \
                -level 3.0 \
                -filter_complex "\
                [0:v]scale=$RESOLUTION:flags=lanczos,zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p[v0]; \
                [1:v]scale=$RESOLUTION:flags=lanczos,zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p[v1]; \
                [v0][0:a][v1][1:a]concat=n=3:v=1:a=1[v][a]"\
                -map "[v]" -map "[a]" \
                "$output"
        else
            echo "Leaving Video as is"
            cp "$video" "$output"
        fi

        if [[ -z $NOUPLOAD ]]; then
            echo "Uploading Processed File to Youtube";
            youtubeuploader -secrets ./client_secrets.json -cache ./request.token -notify=false -ratelimit $RATELIMIT -privacy private -filename "$output" || error=true
            if [[ -n $error ]]; then
                echo "Waiting till midnight"
                eval "$(date +'h=%H m=%M s=%S')"
                seconds=$((86400 - (${h#0} * 3600 + ${m#0} * 60 + ${s#0})))
                echo "$seconds seconds to wait"
                sleep $seconds
                youtubeuploader -secrets ./client_secrets.json -cache ./request.token -notify=false -ratelimit $RATELIMIT -privacy private -filename "$output"
            fi
        fi
    done
echo "Completed Processing Videos"
