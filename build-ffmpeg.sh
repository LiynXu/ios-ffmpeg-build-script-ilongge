#!/bin/sh
current_path=$(
	cd "$(dirname "$0")"
	pwd
)
echo $current_path
cd $current_path

# i386 抛弃吧
# armv7 也抛弃吧
# x86_64 Intel专用 M1模拟器也是ARM64的
# arm64

# 选择编译架构
ARCHS="x86_64 arm64"
# 最低支持版本 2021年了建议iOS11起
DEPLOYMENT_TARGET="13.0"

# 都是已经编译过的插件的相对路径 没事别瞎改哦
# X264=$(pwd)/extend/x264-ios
# X265=$(pwd)/extend/x265-ios
# FDK_AAC=$(pwd)/extend/fdk-aac-ios
# OpenSSL=$(pwd)/extend/openssl-ios
# LAME=$(pwd)/extend/lame-ios

# 编译FFmpeg版本
FFMPEG_VERSION="5.0"

if [[ $FFMPEG_VERSION != "" ]]; then
	FFMPEG_VERSION=$FFMPEG_VERSION
fi
SOURCE="FFmpeg-$FFMPEG_VERSION"
FAT=$(pwd)"/FFmpeg/FFmpeg-$FFMPEG_VERSION-iOS"
SCRATCH=$(pwd)"/FFmpeg/scratch-$FFMPEG_VERSION"
THIN=$(pwd)"/FFmpeg/thin-$FFMPEG_VERSION"

echo "Current_Path         = $(pwd)"
echo "Build_FFmpeg_Version = $FFMPEG_VERSION"
echo "Build_FFmpeg_ARCHS   = $ARCHS"

CONFIGURE_FLAGS="--enable-cross-compile --disable-debug --disable-programs --disable-doc --enable-pic"

if [ $X264 -o $X265 ]; then

	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-gpl"

	if [ "$X264" ]; then
		CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libx264 --enable-encoder=libx264"
	fi
	if [ "$X265" ]; then
		CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libx265  --enable-encoder=libx265"
	fi
fi
if [ $FDK_AAC -o $OpenSSL ]; then

	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-nonfree"

	if [ "$FDK_AAC" ]; then
		CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libfdk_aac --enable-encoder=libfdk_aac"
	fi

	if [ "$OpenSSL" ]; then
		CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-openssl --enable-protocol=http --enable-protocol=https --enable-protocol=hls"
	fi
fi

if [ "$LAME" ]; then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libmp3lame --enable-encoder=libmp3lame"
fi

# # avresample
# #CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-avresample"

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
		# 5.0起编译不再支持iOS 13以下
		VERSION_NEMBER=$(echo $FFMPEG_VERSION | awk '{print int($0)}')
		if [ $VERSION_NEMBER -ge 5 ]; then
			DEPLOYMENT_TARGET="13.0"
		fi
		CFLAGS="-arch $ARCH"
		if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]; then
			PLATFORM="iPhoneSimulator"
			CFLAGS="$CFLAGS -mios-simulator-version-min=$DEPLOYMENT_TARGET"
		else
			PLATFORM="iPhoneOS"
			CFLAGS="$CFLAGS -mios-version-min=$DEPLOYMENT_TARGET -fembed-bitcode"
			if [ "$ARCH" = "arm64" ]; then
				EXPORT="GASPP_FIX_XCODE5=1"
			fi
		fi
		# 4.4起编译带有audiotoolbox的会报错 故按照issue关闭audiotoolbox
		y_or_n=$(echo $FFMPEG_VERSION "4.3" | awk '{if($1 > $2) print 1; else print 0;}')
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

		TMPDIR=${TMPDIR/%\//} $CWD/FFmpeg/$SOURCE/configure \
			--target-os=darwin \
			--arch=$ARCH \
			--cc="$CC" \
			--as="$AS" \
			$CONFIGURE_FLAGS \
			--extra-cflags="$CFLAGS" \
			--extra-ldflags="$LDFLAGS" \
			--prefix="$THIN/$ARCH" ||
			exit 1
		#输出详细编译信息
		echo ./configure /
		echo "\t"--target-os=darwin
		echo "\t"--arch=$ARCH
		echo "\t"--cc="$CC"
		echo "\t"--as="$AS"
		for FLAG in $CONFIGURE_FLAGS; do
			echo "\t"$FLAG
		done
		echo "\n"
		echo --extra-cflags /
		for FLAG in $CFLAGS; do
			echo "\t"$FLAG
		done
		echo "\n"
		echo --extra-ldflags /
		for FLAG in $LDFLAGS; do
			echo "\t"$FLAG
		done
		echo "\n"
		echo --prefix="$THIN/$ARCH"
		#获取机器CPU核心数 就可能加快编译
		THREAD_COUNT=$(sysctl -n machdep.cpu.thread_count)
		echo "make -j $THREAD_COUNT install $EXPORT || exit 1"

		make -j$THREAD_COUNT install $EXPORT || exit 1

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
	fi

	if [ "$X265" ]; then
		Create_Lipo="lipo -create"
		for ARCH in $ARCHS; do
			Create_Lipo="$Create_Lipo $X265/lib/libx265-$ARCH.a"
		done
		Create_Lipo="$Create_Lipo -output $FAT/lib/libx265.a"
		echo $Create_Lipo
		$($Create_Lipo)
	fi

	if [ "$FDK_AAC" ]; then
		Create_Lipo="lipo -create"
		for ARCH in $ARCHS; do
			Create_Lipo="$Create_Lipo $FDK_AAC/lib/libfdk-aac-$ARCH.a"
		done
		Create_Lipo="$Create_Lipo -output $FAT/lib/libfdk-aac.a"
		echo $Create_Lipo
		$($Create_Lipo)
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
	fi

	if [ "$LAME" ]; then
		Create_Lipo="lipo -create"
		for ARCH in $ARCHS; do
			Create_Lipo="$Create_Lipo $LAME/lib/libmp3lame-$ARCH.a"
		done
		Create_Lipo="$Create_Lipo -output $FAT/lib/libmp3lame.a"
		echo $Create_Lipo
		$($Create_Lipo)
	fi

	cd $CWD
	cp -rf $THIN/$1/include $FAT
fi

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+  Congratulations ! ! !                            +"
echo "+  Build FFMpeg-iOS Success ! ! !                   +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
