# FFmpeg iOS build script

Tested with:

* FFmpeg 4.4.1
* Xcode 13.1 (13A1030d)
* MacOS 11.6.1 (20G221)

## Attention

4.4目前无法编译Audiotoolbox，代码中也有写。建议编译4.3.2即可

## Requirements

* https://github.com/libav/gas-preprocessor
* yasm 1.2.0

You should link your app with

* libz.dylib
* libbz2.dylib
* libiconv.dylib

## Thanks
本脚本是摘抄自 [FFmpeg-iOS-build-script](https://github.com/kewlbear/FFmpeg-iOS-build-script/blob/master/build-ffmpeg.sh)

学习后加以改造

感谢原作者！！！