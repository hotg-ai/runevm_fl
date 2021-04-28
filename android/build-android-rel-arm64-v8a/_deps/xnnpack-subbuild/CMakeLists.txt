# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.20.1)

# We name the project and the target for the ExternalProject_Add() call
# to something that will highlight to the user what we are working on if
# something goes wrong and an error message is produced.

project(xnnpack-populate NONE)

# Pass through things we've already detected in the main project to avoid
# paying the cost of redetecting them again in ExternalProject_Add()
set(GIT_EXECUTABLE [==[/usr/local/bin/git]==])
set(GIT_VERSION_STRING [==[2.23.0]==])
set_property(GLOBAL PROPERTY _CMAKE_FindGit_GIT_EXECUTABLE_VERSION
  [==[/usr/local/bin/git;2.23.0]==]
)


include(ExternalProject)
ExternalProject_Add(xnnpack-populate
                     "UPDATE_DISCONNECTED" "False" "GIT_REPOSITORY" "https://github.com/google/XNNPACK" "GIT_TAG" "f0cb70a1ae68c4b99047b7c5d26c40fa3a65f0e4" "GIT_PROGRESS" "TRUE" "PREFIX" "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a"
                    SOURCE_DIR          "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/xnnpack"
                    BINARY_DIR          "/Users/geerttrooskens/dev/src/runevm_fl/android/build-android-rel-arm64-v8a/_deps/xnnpack-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
                    USES_TERMINAL_DOWNLOAD  YES
                    USES_TERMINAL_UPDATE    YES
)


