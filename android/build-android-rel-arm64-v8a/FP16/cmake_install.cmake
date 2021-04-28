# Install script for directory: /Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/FP16-source

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/Users/geerttrooskens/dev/src/runevm_fl/android/install-android-rel-arm64-v8a")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "TRUE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/Users/geerttrooskens/dev/android-ndk-r21b/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android-objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/FP16-source/include/fp16.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/fp16" TYPE FILE FILES
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/FP16-source/include/fp16/bitcasts.h"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/FP16-source/include/fp16/fp16.h"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/FP16-source/include/fp16/psimd.h"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/FP16-source/include/fp16/__init__.py"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/FP16-source/include/fp16/avx.py"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/FP16-source/include/fp16/avx2.py"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/psimd/cmake_install.cmake")

endif()

