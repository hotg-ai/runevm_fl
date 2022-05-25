cmake_minimum_required(VERSION 3.6)

# Settings
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "-Werror=return-type")

# TODO: This is a bit too specific - room for improvement is there
set(RUNE_INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../rune)

set(TARGET_NAME rune_vm_loader)

# Add loader target
set(TARGET_NAME rune_vm_loader)
add_library(
    ${TARGET_NAME}
    SHARED
    ${CMAKE_CURRENT_SOURCE_DIR}/jni.cpp
    ${RUNE_INSTALL_DIR}/include
)

# Add librune_native as imported library because its shared and we need packager to install it on device
set(RUNE_LIBRARY_DIR ${RUNE_INSTALL_DIR}/lib)

set(RUNE_LIB_TARGET_NAME librune_native)
add_library(
    ${RUNE_LIB_TARGET_NAME}
    STATIC
    IMPORTED)

set_target_properties(
    ${RUNE_LIB_TARGET_NAME}
    PROPERTIES IMPORTED_LOCATION
    ${RUNE_LIBRARY_DIR}/librune_native.a)

# Add librunecoral as imported library because its shared and we need packager to install it on device
set(RUNE_CORAL_TARGET_NAME librunecoral)
add_library(
    ${RUNE_CORAL_TARGET_NAME}
    STATIC
    IMPORTED)

set_target_properties(
    ${RUNE_CORAL_TARGET_NAME}
    PROPERTIES IMPORTED_LOCATION
    ${RUNE_LIBRARY_DIR}/librunecoral.a)

target_link_libraries(
        ${TARGET_NAME}
        PRIVATE
        android
        log
        ${RUNE_LIB_TARGET_NAME}
        ${RUNE_CORAL_TARGET_NAME}
)

target_include_directories(
    ${TARGET_NAME}
    PRIVATE
    ${RUNE_INSTALL_DIR}/include
)
