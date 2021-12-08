# FFmpeg iOS build script

## 测试环境:

* FFmpeg 4.4.1
* Xcode 13.1 (13A1030d)
* MacOS 11.6.1 (20G221)

## 注意事项

* 4.4目前无法编译Audiotoolbox，代码中也有写。建议编译4.3.2即可

## 编译依赖

* https://github.com/libav/gas-preprocessor
* yasm 1.2.0

## 使用方法

设定FFMpeg架构

```
# i386 抛弃吧
# armv7 也抛弃吧
# x86_64 Intel专用 M1模拟器也是ARM64的
# arm64

# 选择编译架构
ARCHS="x86_64 arm64"
# 最低支持版本 2021年了建议iOS11起
DEPLOYMENT_TARGET="8.0"
```

设定编译FFMpeg版本

```
# 编译FFmpeg版本
FFMPEG_VERSION="4.4.1"
```

进入到当前目录直接执行脚本即可，如遇无法执行，可能是文件权限问题

```
cd ios-ffmpeg-build-script-ilongge
./build-ffmpeg.sh   

```


## 使用依赖

* VideotoolBox
* Audiotoolbox
* libz.dylib
* libbz2.dylib
* libiconv.dylib

## Thanks
本脚本是摘抄自 [FFmpeg-iOS-build-script](https://github.com/kewlbear/FFmpeg-iOS-build-script/blob/master/build-ffmpeg.sh)

学习后加以改造

感谢原作者！！！