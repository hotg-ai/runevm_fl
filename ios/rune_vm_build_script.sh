# Configure
PROJECT_DIR=$(pwd)
BUILD_DIR="rune_vm_build"
RUNE_VM_PROJECT_DIR=$PROJECT_DIR/../extern/rune_vm
RUNE_VM_INSTALL_DIR=$PROJECT_DIR
CONFIG_POSTFIX=ios-rel
BUILD_DIR=build-$CONFIG_POSTFIX
mkdir -p $PROJECT_DIR/$BUILD_DIR && cd $PROJECT_DIR/$BUILD_DIR
export POLLY_IOS_DEVELOPMENT_TEAM="SV35KN42GY"
export POLLY_IOS_BUNDLE_IDENTIFIER="ai.hotg.runicapp"
export PATH_TO_TFLITE_FRAMEWORK="$PROJECT_DIR/TensorFlowLiteC.framework"
cmake $RUNE_VM_PROJECT_DIR \
    -GXcode \
    -DRUNE_VM_BUILD_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX=$RUNE_VM_INSTALL_DIR/install-$CONFIG_POSTFIX \
    -DCMAKE_TOOLCHAIN_FILE=$RUNE_VM_PROJECT_DIR/extern/polly/ios.cmake \
    -DRUNE_VM_TFLITE_EXTERNAL=ON \
    -DRUNE_VM_INFERENCE_TFLITE_INCLUDE_DIRS=$PATH_TO_TFLITE_FRAMEWORK/Headers \
    -DRUNE_VM_INFERENCE_TFLITE_LIBRARIES=$PATH_TO_TFLITE_FRAMEWORK/TensorFlowLiteC

# Build
BUILD_WORKERS_COUNT=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null)
cmake --build ./ --target rune_vm --config Debug --parallel $BUILD_WORKERS_COUNT

# Install
cmake --build ./ --target install --config Debug --parallel $BUILD_WORKERS_COUNT
