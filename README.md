# FFmpeg iOS build script

## 测试环境:

* FFmpeg 5.0
* Xcode 13.2.1 (13C100)
* MacOS 11.6.5 (20G527)

## 注意事项

* 4.4+ 无法编译Audiotoolbox
* 5.0+ 仅支持iOS13及以上

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
```
设定最低支持的系统版本

```
# 最低支持版本 2022年了建议iOS11起
DEPLOYMENT_TARGET="13.0"
```

设定编译FFMpeg版本

```
# 编译FFmpeg版本
FFMPEG_VERSION="5.0"
```

进入到当前目录直接执行脚本即可，如遇无法执行，可能是文件权限问题

```
cd ios-ffmpeg-build-script-ilongge
chmod +x build-ffmpeg.sh
./build-ffmpeg.sh   

```


## 使用依赖

不一定都需要，看实际的编译参数所开启的功能

系统原生框架

* AppKit
* AVFoundation
* CoreImage
* VideotoolBox
* Audiotoolbox
* CoreFoundation
* CoreMedia
* CoreVideo

系统库

* libz.dylib
* libbz2.dylib
* libiconv.dylib

## Thanks
本脚本是摘抄自 [FFmpeg-iOS-build-script](https://github.com/kewlbear/FFmpeg-iOS-build-script/blob/master/build-ffmpeg.sh)

学习后加以改造

感谢原作者！！！

[Gitee仓库](https://gitee.com/ilongge/ios-ffmpeg-build-script-ilongge.git)