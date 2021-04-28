# Install script for directory: /Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen

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

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xDevelx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/eigen3/unsupported/Eigen" TYPE FILE FILES
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/AdolcForward"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/AlignedVector3"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/ArpackSupport"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/AutoDiff"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/BVH"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/EulerAngles"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/FFT"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/IterativeSolvers"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/KroneckerProduct"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/LevenbergMarquardt"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/MatrixFunctions"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/MoreVectorization"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/MPRealSupport"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/NonLinearOptimization"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/NumericalDiff"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/OpenGLSupport"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/Polynomials"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/Skyline"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/SparseExtra"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/SpecialFunctions"
    "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/Splines"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xDevelx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/eigen3/unsupported/Eigen" TYPE DIRECTORY FILES "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/eigen/unsupported/Eigen/src" FILES_MATCHING REGEX "/[^/]*\\.h$")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/_deps/eigen-build/unsupported/Eigen/CXX11/cmake_install.cmake")

endif()

