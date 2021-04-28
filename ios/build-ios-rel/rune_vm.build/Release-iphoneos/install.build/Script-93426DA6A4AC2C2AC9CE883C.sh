#!/bin/sh
set -e
if test "$CONFIGURATION" = "Debug"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  /usr/local/Cellar/cmake/3.20.1/bin/cmake -DBUILD_TYPE=$CONFIGURATION -DEFFECTIVE_PLATFORM_NAME=$EFFECTIVE_PLATFORM_NAME -P cmake_install.cmake
fi
if test "$CONFIGURATION" = "Release"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  /usr/local/Cellar/cmake/3.20.1/bin/cmake -DBUILD_TYPE=$CONFIGURATION -DEFFECTIVE_PLATFORM_NAME=$EFFECTIVE_PLATFORM_NAME -P cmake_install.cmake
fi
if test "$CONFIGURATION" = "MinSizeRel"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  /usr/local/Cellar/cmake/3.20.1/bin/cmake -DBUILD_TYPE=$CONFIGURATION -DEFFECTIVE_PLATFORM_NAME=$EFFECTIVE_PLATFORM_NAME -P cmake_install.cmake
fi
if test "$CONFIGURATION" = "RelWithDebInfo"; then :
  cd /Users/geerttrooskens/dev/src/runevm_fl/ios/build-ios-rel
  /usr/local/Cellar/cmake/3.20.1/bin/cmake -DBUILD_TYPE=$CONFIGURATION -DEFFECTIVE_PLATFORM_NAME=$EFFECTIVE_PLATFORM_NAME -P cmake_install.cmake
fi

