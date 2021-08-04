# /bin/sh
# 1. run it from the runic_mobile/android directory
# 2. specify NDK_PATH 
echo "Configure"

PROJECT_DIR=$(pwd)/../extern/rune_vm
INSTALL_DIR=$(pwd)
ABI=arm64-v8a
CONFIG_POSTFIX=android-rel-$ABI
BUILD_DIR=build-$CONFIG_POSTFIX
mkdir -p $BUILD_DIR && cd $BUILD_DIR
NDK_PATH=/Users/geerttrooskens/dev/android-ndk-r21e
cmake $PROJECT_DIR \
    -DTFLITE_C_BUILD_SHARED_LIBS=ON \
    -DRUNE_VM_BUILD_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/install-$CONFIG_POSTFIX \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_ARM_NEON=ON \
    -DANDROID_NDK=$NDK_PATH \
    -DANDROID_NATIVE_API_LEVEL=21 \
    -DANDROID_STL=c++_shared \
    -DANDROID_TOOLCHAIN=clang \
    -DCMAKE_TOOLCHAIN_FILE=$NDK_PATH/build/cmake/android.toolchain.cmake

echo "Build"
BUILD_WORKERS_COUNT=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null)
cmake --build ./ --target rune_vm --config Release --parallel $BUILD_WORKERS_COUNT

echo "Install"
cmake --build ./ --target install --config Release --parallel $BUILD_WORKERS_COUNT