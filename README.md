# RapiPub
A Dockerized Rapid Social Media Video Processing and Publishing Micro Service

## Features
* watch a folder of nested video files
* prepend video with intro if available
* append video with outro if available
* skip conversions if not neccessary
* handle resolution scaling
* handle HDR to SDR conversions
* upload to youtube using minimal bandwidth
* keep videos private until metadata can be added.

## Requirments

* (https://github.com/porjo/youtubeuploader)[youtubeuploader]
* ffmpeg
* intro and outro in m4v format(for dockerized version only)
* google developer console youtube data api v3 oauth credentials
* a youtube account

## Setup
1. setup the google developer console following the readme on the youtubeuploader dependency
1. run youtubeuploader to generate a request.token file.
1. run command.sh like `./command.sh <path-to-source-media-folder> <path-to-destination-folder> <path-to-intro-video-file> <path-to-outro-video-file> <3840x2160|1920x1080|...> <libx265|hevc_videotoolbox> <ratelimit-in-Kbps>`
