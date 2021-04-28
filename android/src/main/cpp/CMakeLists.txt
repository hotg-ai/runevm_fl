cmake_minimum_required(VERSION 3.6)

# Settings
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "-Werror=return-type")

# TODO: This is a bit too specific - room for improvement is there
set(RUNE_VM_INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../install-android-rel-arm64-v8a)
set(RUNIC_MOBILE_COMMON_CPP_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../cpp)
# TODO: refactor - this is bad
set(RUNE_VM_SUBMODULE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../extern)

# Add loader target
set(TARGET_NAME rune_vm_loader)
add_library(
    ${TARGET_NAME}
    SHARED
    ${CMAKE_CURRENT_SOURCE_DIR}/jni.cpp
    ${RUNIC_MOBILE_COMMON_CPP_DIR}/runic.cpp
    ${RUNIC_MOBILE_COMMON_CPP_DIR}/runic.hpp)

# Add tensorflow as imported library because its shared and we need packager to install it on device
set(RUNE_VM_LIBRARY_DIR ${RUNE_VM_INSTALL_DIR}/lib/${ANDROID_ABI})
set(TENSORFLOW_LITE_C_TARGET_NAME libtensorflowlite_c)
add_library(
    ${TENSORFLOW_LITE_C_TARGET_NAME}
    SHARED
    IMPORTED)

set_target_properties(
    ${TENSORFLOW_LITE_C_TARGET_NAME}
    PROPERTIES IMPORTED_LOCATION
    ${RUNE_VM_LIBRARY_DIR}/libtensorflowlite_c.so)

# Add rune_vm as imported library because its shared and we need packager to install it on device
set(RUNE_VM_TARGET_NAME librune_vm)
add_library(
    ${RUNE_VM_TARGET_NAME}
    SHARED
    IMPORTED)

set_target_properties(
    ${RUNE_VM_TARGET_NAME}
    PROPERTIES IMPORTED_LOCATION
    ${RUNE_VM_LIBRARY_DIR}/librune_vm.so)

# Include libraries needed for rune_vm_loader lib
target_link_libraries(
    ${TARGET_NAME}
    PRIVATE
    android
    log
    ${RUNE_VM_TARGET_NAME}
    ${TENSORFLOW_LITE_C_TARGET_NAME}
)

target_include_directories(
    ${TARGET_NAME}
    PRIVATE
    ${RUNE_VM_INSTALL_DIR}/include
    ${RUNIC_MOBILE_COMMON_CPP_DIR}
    ${RUNE_VM_SUBMODULE_DIR}/fmt/include
)
