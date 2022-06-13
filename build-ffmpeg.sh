#!/bin/sh
current_path=$(
	cd "$(dirname "$0")"
	pwd
)
echo $current_path
cd $current_path

# 单纯为了播放
OnlyForPlayer=''

# 静态库
Static='y'

# 都是已经编译过的插件的相对路径 没事别瞎改哦
# X264=$(pwd)/extend/x264-ios
# X265=$(pwd)/extend/x265-ios
# X265=$(pwd)/extend/libx265-ios
# FDK_AAC=$(pwd)/extend/fdk-aac-ios
# OpenSSL=$(pwd)/extend/openssl-ios
# LAME=$(pwd)/extend/lame-ios

# 编译FFmpeg版本
FFMPEG_VERSION="5.0.1"

if [[ $FFMPEG_VERSION != "" ]]; then
	FFMPEG_VERSION=$FFMPEG_VERSION
fi

# i386      抛弃吧
# armv7     也抛弃吧
# x86_64    Intel版Macbook的Xcode模拟器专用 M1版的Xcode模拟器是ARM64的
# arm64     目前主流的ios设备架构

# 选择编译架构
ARCHS="armv7 arm64 x86_64" 

# 最低支持版本 2022年了建议iOS11起
DEPLOYMENT_TARGET="9.0"
# 5.0起编译不再支持iOS 13以下
ffmpeg5=$(echo $FFMPEG_VERSION "5.0" | awk '{if($1 >= $2) print 1; else print 0;}')
if [ $ffmpeg5 -eq 1 ]; then
	DEPLOYMENT_TARGET="13.0"
fi
#移除低版本的Armv7支持
ios11=$(echo $DEPLOYMENT_TARGET "11.0" | awk '{if($1 >= $2) print 1; else print 0;}')
if [ $ios11 -eq 1 ]; then 
	if [[ $ARCHS == *"armv7"* ]]; then
		ARCHS=$(echo $ARCHS | sed 's/armv7//g')
	fi
fi 

SOURCE="FFmpeg-$FFMPEG_VERSION"
FAT=$(pwd)"/FFmpeg/FFmpeg-$FFMPEG_VERSION-iOS"
SCRATCH=$(pwd)"/FFmpeg/scratch-$FFMPEG_VERSION"
THIN=$(pwd)"/FFmpeg/thin-$FFMPEG_VERSION"

echo "Current_Path         = $(pwd)"
echo "Build_FFmpeg_Version = $FFMPEG_VERSION"
echo "Build_FFmpeg_ARCHS   = $ARCHS"

if [ "$Static" ]; then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-static"
else
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-shared"
fi

CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-cross-compile"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-debug"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-programs"
# CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-ffmpeg"
# CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-ffplay"
# CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-ffprobe"

CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-doc"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-htmlpages"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-manpages"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-podpages"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-txtpages"

CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-pic"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-small"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-postproc"
if [ $ffmpeg5 -eq 0 ]; then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-avresample"
fi
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-swscale-alpha"

CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-hwaccels"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-videotoolbox"

if [ "$OnlyForPlayer" ]; then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-decoders"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=aac"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=aac_latm"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=ac3"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=ass"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=avs"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=bmp"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=eac3"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=flac"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=flv"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=h261"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=h264"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=hevc"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=jpeg2000"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=mp3"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=mp3float"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=mpeg1video"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=mpeg2video"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=mpeg4"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=mp2float"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=mjpeg"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=opus"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=png"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=srt"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=ssa"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=tiff"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=vc1"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=vp7"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=vp8"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=vp9"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=webp"

	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-encoders"

	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-parsers"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=aac"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=aac_latm"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=ac3"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=av1"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=avs2"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=bmp"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=flac"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=h261"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=h263"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=h264"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=hevc"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=jpeg2000"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=mpegaudio"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=mpegvideo"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=opus"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=png"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=vc1"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=vp8"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-parser=vp9"

	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-demuxers"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=aac"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=ac3"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=av1"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=avi"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=avs"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=avs2"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=caf"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=data"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=dts"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=dtshd"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=eac3"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=flac"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=flv"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=h261"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=h263"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=h264"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=hevc"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=hls"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=image2"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=m4v"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=matroska"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=mp3"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=mov"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=mpegps"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=mpegts"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=mpegvideo"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=rm"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=rtp"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=rtsp"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=srt"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=vc1"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-demuxer=wav"

	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-muxers"

	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-protocols"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=tcp"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=udp"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=http"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=https"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=file"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=ftp"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=hls"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=tls"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=ffrtmphttp"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=rtp"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=rtmp"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=rtmpt"

	# CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-bsfs"

	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-indevs"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-indev=avfoundation"

	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-filters"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-filter=aformat"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-filter=aresample"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-filter=volume"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-filter=scale"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-filter=transpose"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-filter=acrossfade"

	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-outdevs"
fi

if [ "$X264" ]; then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libx264"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-encoder=libx264"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-gpl"
fi

if [ "$X265" ]; then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libx265"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-encoder=libx265"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-gpl"
fi

if [ "$FDK_AAC" ]; then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libfdk_aac"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-encoder=libfdk_aac"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-nonfree"
fi

if [ "$OpenSSL" ]; then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-openssl"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=https"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-nonfree"
fi

if [ "$LAME" ]; then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libmp3lame"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-encoder=libmp3lame"
fi

COMPILE="y"
LIPO="y"

if [ "$*" ]; then
	if [ "$*" = "lipo" ]; then
		# skip compile
		COMPILE=
	else
		ARCHS="$*"
		if [ $# -eq 1 ]; then
			# skip lipo
			LIPO=
		fi
	fi
fi

if [ "$COMPILE" ]; then
	if [ ! $(which yasm) ]; then
		echo 'Yasm not found'
		if [ ! $(which brew) ]; then
			echo 'Homebrew not found. Trying to install...'
			ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" ||
				exit 1
		fi
		echo 'Trying to install Yasm...'
		brew install yasm || exit 1
	fi
	if [ ! $(which gas-preprocessor.pl) ]; then
		echo 'gas-preprocessor.pl not found. Trying to install...'
		(curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
			-o /usr/local/bin/gas-preprocessor.pl &&
			chmod +x /usr/local/bin/gas-preprocessor.pl) ||
			exit 1
	fi

	if [ ! -r FFmpeg/FFmpeg-$FFMPEG_VERSION ]; then
		SOURCE_URL=http://www.ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.bz2
		echo 'FFmpeg source not found.'
		echo 'Trying to download from '$SOURCE_URL
		curl $SOURCE_URL | tar xj ||
			exit 1
		echo mv ffmpeg-$FFMPEG_VERSION FFmpeg/FFmpeg-$FFMPEG_VERSION
		mv ffmpeg-$FFMPEG_VERSION FFmpeg/FFmpeg-$FFMPEG_VERSION
	fi

	CWD=$(pwd)
	for ARCH in $ARCHS; do
		echo "building $ARCH..."
		mkdir -p "$SCRATCH/$ARCH"
		cd "$SCRATCH/$ARCH"

		ARCH_OPTIONS=""
		NEON_FLAG=""
		CFLAGS="-arch $ARCH"
		if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]; then
			PLATFORM="iPhoneSimulator"
			NEON_FLAG="$NEON_FLAG --disable-neon"
			ARCH_OPTIONS="$ARCH_OPTIONS --disable-asm"
			CFLAGS="$CFLAGS -mios-simulator-version-min=$DEPLOYMENT_TARGET"
		else
			PLATFORM="iPhoneOS"
			CFLAGS="$CFLAGS -mios-version-min=$DEPLOYMENT_TARGET -fembed-bitcode"
			if [ "$ARCH" = "arm64" ]; then
				EXPORT="GASPP_FIX_XCODE5=1"
			fi
			NEON_FLAG="$NEON_FLAG --enable-neon"
			ARCH_OPTIONS="$ARCH_OPTIONS --enable-asm"
		fi
		# 4.4起编译需关闭audiotoolbox
		y_or_n=$(echo $FFMPEG_VERSION "4.4" | awk '{if($1 >= $2) print 1; else print 0;}')
		if [ $y_or_n -eq 1 ]; then
			CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-audiotoolbox"
		fi
		XCRUN_SDK=$(echo $PLATFORM | tr '[:upper:]' '[:lower:]')
		CC="xcrun -sdk $XCRUN_SDK clang"

		# force "configure" to use "gas-preprocessor.pl" (FFmpeg 3.3)
		if [ "$ARCH" = "arm64" ]; then
			AS="gas-preprocessor.pl -arch aarch64 -- $CC"
		else
			AS="gas-preprocessor.pl -- $CC"
		fi

		CXXFLAGS="$CFLAGS"
		LDFLAGS="$CFLAGS"

		if [ "$X264" ]; then
			CFLAGS="$CFLAGS -I$X264/include"
			LDFLAGS="$LDFLAGS -L$X264/lib"
		fi

		if [ "$X265" ]; then
			CFLAGS="$CFLAGS -I$X265/include"
			LDFLAGS="$LDFLAGS -L$X265/lib"
		fi

		if [ "$FDK_AAC" ]; then
			CFLAGS="$CFLAGS -I$FDK_AAC/include"
			LDFLAGS="$LDFLAGS -L$FDK_AAC/lib"
		fi

		if [ "$OpenSSL" ]; then
			CFLAGS="$CFLAGS -I$OpenSSL/include"
			LDFLAGS="$LDFLAGS -L$OpenSSL/lib -lcrypto -lssl"
		fi

		if [ "$LAME" ]; then
			CFLAGS="$CFLAGS -I$LAME/include"
			LDFLAGS="$LDFLAGS -L$LAME/lib"
		fi

		#输出详细编译信息
		echo $CWD/FFmpeg/$SOURCE
		echo configure
		echo --target-os=darwin
		echo --arch=$ARCH
		echo --cc="$CC"
		echo --as="$AS"
		echo $CONFIGURE_FLAGS
		echo --extra-cflags $CFLAGS
		echo --extra-ldflags $LDFLAGS
		echo --prefix="$THIN/$ARCH"
		echo $NEON_FLAG
		echo $ARCH_OPTIONS

		TMPDIR=${TMPDIR/%\//} $CWD/FFmpeg/$SOURCE/configure \
			--target-os=darwin \
			--arch=$ARCH \
			--cc="$CC" \
			--as="$AS" \
			--extra-cflags="$CFLAGS" \
			--extra-ldflags="$LDFLAGS" \
			--prefix="$THIN/$ARCH" \
			$CONFIGURE_FLAGS \
			$NEON_FLAG \
			$ARCH_OPTIONS ||
			exit 1

		make -j install $EXPORT || exit 1

		cd $CWD

	done
fi

if [ "$LIPO" ]; then
	echo "building fat binaries..."
	mkdir -p $FAT/lib
	set - $ARCHS
	CWD=$(pwd)
	cd $THIN/$1/lib
	for LIB in *.a; do
		cd $CWD
		echo lipo -create $(find $THIN -name $LIB) -output $FAT/lib/$LIB 1>&2
		lipo -create $(find $THIN -name $LIB) -output $FAT/lib/$LIB || exit 1
	done

	if [ "$X264" ]; then
		Create_Lipo="lipo -create"
		for ARCH in $ARCHS; do
			Create_Lipo="$Create_Lipo $X264/lib/libx264-$ARCH.a"
		done
		Create_Lipo="$Create_Lipo -output $FAT/lib/libx264.a"
		echo $Create_Lipo
		$($Create_Lipo)
		echo cp -r $X264/include $FAT/include
		cp -r $X264/include/* $FAT/include
	fi

	if [ "$X265" ]; then
		Create_Lipo="lipo -create"
		for ARCH in $ARCHS; do
			Create_Lipo="$Create_Lipo $X265/lib/libx265-$ARCH.a"
		done
		Create_Lipo="$Create_Lipo -output $FAT/lib/libx265.a"
		echo $Create_Lipo
		$($Create_Lipo)
		echo cp -r $X265/include $FAT/include
		cp -r $X265/include/* $FAT/include
	fi

	if [ "$FDK_AAC" ]; then
		Create_Lipo="lipo -create"
		for ARCH in $ARCHS; do
			Create_Lipo="$Create_Lipo $FDK_AAC/lib/libfdk-aac-$ARCH.a"
		done
		Create_Lipo="$Create_Lipo -output $FAT/lib/libfdk-aac.a"
		echo $Create_Lipo
		$($Create_Lipo)
		echo cp -r $FDK_AAC/include $FAT/include
		cp -r $FDK_AAC/include/* $FAT/include
	fi

	if [ "$OpenSSL" ]; then
		Create_Lipo="lipo -create"
		for ARCH in $ARCHS; do
			Create_Lipo="$Create_Lipo $OpenSSL/lib/libcrypto-$ARCH.a"
		done
		Create_Lipo="$Create_Lipo -output $FAT/lib/libcrypto.a"
		echo $Create_Lipo
		$($Create_Lipo)

		Create_Lipo="lipo -create"
		for ARCH in $ARCHS; do
			Create_Lipo="$Create_Lipo $OpenSSL/lib/libssl-$ARCH.a"
		done
		Create_Lipo="$Create_Lipo -output $FAT/lib/libssl.a"
		echo $Create_Lipo
		$($Create_Lipo)
		echo cp -r $OpenSSL/include $FAT/include
		cp -r $OpenSSL/include/* $FAT/include
	fi

	if [ "$LAME" ]; then
		Create_Lipo="lipo -create"
		for ARCH in $ARCHS; do
			Create_Lipo="$Create_Lipo $LAME/lib/libmp3lame-$ARCH.a"
		done
		Create_Lipo="$Create_Lipo -output $FAT/lib/libmp3lame.a"
		echo $Create_Lipo
		$($Create_Lipo)

		echo cp -r $LAME/lame $FAT/include
		cp -r $LAME/include/* $FAT/include
	fi

	cd $CWD
	cp -rf $THIN/$1/include $FAT
fi

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+  Congratulations ! ! !                            +"
echo "+  Build FFMpeg-iOS Success ! ! !                   +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
