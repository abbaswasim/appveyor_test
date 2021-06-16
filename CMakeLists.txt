# WatchCat Source Code
# Wasim Abbas
# http://www.waZim.com
# Copyright (c) 2020
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the 'Software'),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Version: 1.0.0

cmake_minimum_required (VERSION 3.12)

project(WatchCat VERSION 1.1.0.0 LANGUAGES CXX C)
list(APPEND CMAKE_MESSAGE_CONTEXT Watch_Cat)

set(WATCHCAT_NAME watchcat)

set(WATCHCAT_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR}) # Always prefer the _LIST_ version FILES/DIRS instead of the _SOURCE_
set(WATCHCAT_SOURCE_DIR ${WATCHCAT_ROOT_DIR})

include(${WATCHCAT_ROOT_DIR}/build.cmake)
include(${WATCHCAT_ROOT_DIR}/cmake/cputypetest.cmake)
include(${WATCHCAT_ROOT_DIR}/cmake/cputest.cmake)

target_architecture(CPU_ARCHITECTURE_2)

message(STATUS "CPU_ARCHITECTURE2 was set to ${CPU_ARCHITECTURE_2}")

set_target_processor_type(CPU_ARCHITECTURE)
if(CPU_ARCHITECTURE STREQUAL x86_64)
    message(STATUS "CPU_ARCHITECTURE was set to ${CPU_ARCHITECTURE}")
elseif(CPU_ARCHITECTURE STREQUAL x86)
    message(STATUS "CPU_ARCHITECTURE was set to ${CPU_ARCHITECTURE}")
else()
    message(STATUS "CPU_ARCHITECTURE was set to nothing but here it is = ${CPU_ARCHITECTURE}")
endif()

# Always generate compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

# Configure version source file watchcat_version.cpp
configure_file(${WATCHCAT_SOURCE_DIR}/watchcat_version.cpp.in watchcat_version.cpp @ONLY)
add_library(watchcat_version STATIC ${CMAKE_CURRENT_BINARY_DIR}/watchcat_version.cpp)
target_include_directories(watchcat_version PUBLIC ${CMAKE_CURRENT_LIST_DIR})

set(WATCHCAT_HEADERS
  ${WATCHCAT_SOURCE_DIR}/watchcat.hpp)

set(WATCHCAT_SOURCES
  ${WATCHCAT_SOURCE_DIR}/watchcat.cpp)

add_library(${WATCHCAT_NAME} SHARED ${WATCHCAT_SOURCES} ${WATCHCAT_HEADERS})
# add_executable(${WATCHCAT_NAME} ${WATCHCAT_SOURCES} ${WATCHCAT_HEADERS})

set_target_properties(${WATCHCAT_NAME} PROPERTIES VERSION 1.0.0.0 SOVERSION 1)          # TODO: Fix the hardcoded version
set_target_properties(${WATCHCAT_NAME} PROPERTIES CMAKE_VISIBILITY_INLINES_HIDDEN true) # Don't export all of those C++ template generated symbols
set_target_properties(${WATCHCAT_NAME} PROPERTIES CMAKE_CXX_VISIBILITY_PRESET hidden)   # Set default to hide symbols visibility for WatchCat
set_target_properties(${WATCHCAT_NAME} PROPERTIES CMAKE_C_VISIBILITY_PRESET hidden)     # Set default to hide symbols visibility for WatchCat

set(CMAKE_VISIBILITY_INLINES_HIDDEN YES)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)    # Set default to hide symbols visibility for all targets
set(CMAKE_C_VISIBILITY_PRESET hidden)      # Set default to hide symbols visibility for all targets

# Only use the below if building library
message(STATUS "Now generating watchcat_export_import.h file")
include(GenerateExportHeader)
generate_export_header(${WATCHCAT_NAME}
  EXPORT_FILE_NAME watchcat_export_import.hpp
  EXPORT_MACRO_NAME WATCHCAT_ITEM
  NO_EXPORT_MACRO_NAME WATCHCAT_PRIVATE)

target_include_directories(${WATCHCAT_NAME} PUBLIC ${CMAKE_CURRENT_BINARY_DIR})
target_include_directories(${WATCHCAT_NAME} PRIVATE ${WATCHCAT_SOURCE_DIR})
target_include_directories(${WATCHCAT_NAME} PRIVATE ${WATCHCAT_ROOT_DIR})

set(WATCHCAT_REQUIRED_LIBRARIES
  watchcat_version)

target_link_libraries(${WATCHCAT_NAME} PRIVATE ${WATCHCAT_REQUIRED_LIBRARIES})

build_options(${WATCHCAT_NAME}) # Set common build options
