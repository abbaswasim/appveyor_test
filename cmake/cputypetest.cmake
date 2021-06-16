# Copyright 2016, Simon Werta (@webmaster128).
# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 2.8.12)

configure_file(${CMAKE_SOURCE_DIR}/cputypetest.c ${CMAKE_BINARY_DIR}/cputypetest.c COPYONLY)
message(STATUS "Just wrote ${CMAKE_BINARY_DIR}/cputypetest.c")
message(STATUS "Just wrote ${CMAKE_BINARY_DIR}/cputypetest.c from ${CMAKE_SOURCE_DIR}/cputypetest.c")

if(EXISTS "${CMAKE_SOURCE_DIR}/cputypetest.c")
  message(STATUS "It exisits in sourcd")
else()
  message(STATUS "It does not exisits in sourcd")
endif()

if(EXISTS "${CMAKE_BINARY_DIR}/cputypetest.c")
  message(STATUS "It also exisits in sourcd")
else()
  message(STATUS "It also does not exisits in sourcd")
endif()

cmake_policy(SET CMP0054 NEW)

function(set_target_processor_type out)
    if(ANDROID_ABI AND "${ANDROID_ABI}" STREQUAL "armeabi-v7a")
        set(${out} armv7 PARENT_SCOPE)
    elseif(ANDROID_ABI AND "${ANDROID_ABI}" STREQUAL "arm64-v8a")
        set(${out} armv8 PARENT_SCOPE)
    elseif(ANDROID_ABI AND "${ANDROID_ABI}" STREQUAL "x86")
        set(${out} x86 PARENT_SCOPE)
    elseif(ANDROID_ABI AND "${ANDROID_ABI}" STREQUAL "x86_64")
        set(${out} x86_64 PARENT_SCOPE)

    message(STATUS "Taking android path")
    else()
        message(STATUS "Taking else android path")
        if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
            message(STATUS "Found MSVC")
            set(C_PREPROCESS ${CMAKE_C_COMPILER} /EP /nologo)
            if("${CMAKE_GENERATOR_PLATFORM}" STREQUAL "ARM")
                set(processor "arm")
            elseif("${CMAKE_GENERATOR_PLATFORM}" STREQUAL "ARM64")
                set(processor "arm64")
            else()
                set(C_PREPROCESS "${CMAKE_C_COMPILER} /EP /nologo")
                message(STATUS "Found MSVC non-arm will be running ${C_PREPROCESS}")
                execute_process(
                    COMMAND ${C_PREPROCESS} "${CMAKE_SOURCE_DIR}/cputypetest.c"
                    OUTPUT_VARIABLE processor
                    ERROR_VARIABLE processor_e
                    RESULT_VARIABLE processor_res
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    COMMAND_ECHO STDOUT
                )
                message(STATUS "Execute process finished processor = ${processor}, and ${processor_res}, ${processor_e}")

                execute_process(
                    COMMAND ${C_PREPROCESS} "${CMAKE_BINARY_DIR}/cputypetest.c"
                    OUTPUT_VARIABLE processor2
                    ERROR_VARIABLE processor_e2
                    RESULT_VARIABLE processor_res2
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    COMMAND_ECHO STDOUT
                )
                message(STATUS "Second execute process finished processor = ${processor2}, and ${processor_res2}, ${processor_e2}")

                execute_process(
                    COMMAND ${C_PREPROCESS} "${CMAKE_BINARY_DIR}/nothing.c"
                    OUTPUT_VARIABLE processor3
                    ERROR_VARIABLE processor_e3
                    RESULT_VARIABLE processor_res3
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    COMMAND_ECHO STDOUT
                )
                message(STATUS "Third execute process finished processor = ${processor3}, and ${processor_res3}, ${processor_e3}")
            endif()
        else()
            if(APPLE AND NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
                # No other Apple systems are x64_64. When configuring for iOS, etc.
                # CMAKE_C_COMPILER points at the HOST compiler - I can't find
                # definitive documentation of what is supposed to happen - the
                # test program above returns x86_64. Since we don't care what
                # type of ARM processor arbitrarily set armv8 for these systems.
                set(processor armv8)
            else()
                if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
                    if (CMAKE_OSX_SYSROOT)
                        set(TC_INCLUDE_DIR -I ${CMAKE_OSX_SYSROOT}/usr/include)
                    else()
                        # I have seen cases where CMAKE_OSX_SYSROOT is not defined
                        # for reasons I do not understand. Plus, uses can manually
                        # undefine it. This is the fallback.
                        set(TC_INCLUDE_DIR -I /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include)
                    endif()
                endif()
                set(C_PREPROCESS ${CMAKE_C_COMPILER} ${TC_INCLUDE_DIR} -E -P)
                execute_process(
                    COMMAND ${C_PREPROCESS} "${CMAKE_BINARY_DIR}/cputypetest.c"
                    OUTPUT_VARIABLE processor
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                )
            endif()
        endif()
        message(STATUS "Processor is = ${processor}")
        string(STRIP "${processor}" processor)
        set(${out} ${processor} PARENT_SCOPE)
    endif()
endfunction(set_target_processor_type)
