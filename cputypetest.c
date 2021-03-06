
//
// https://gist.github.com/webmaster128/e08067641df1dd784eb195282fd0912f
//
// The resulting values must not be defined as macros, which
// happens e.g. for 'i386', which is a macro in clang.
// For safety reasons, we undefine everything we output later
//
// For CMake literal compatibility, this file must have no double quotes
//
#if defined (_WIN32)
    #if defined (_WIN64)
        #undef x86_64
x86_64
    #else
        #undef x86
x86
    #endif
#elif defined __APPLE__
    #include <TargetConditionals.h>
    #if TARGET_OS_IPHONE
        #if TARGET_CPU_X86
            #undef x86
x86
        #elif TARGET_CPU_X86_64
            #undef x86_64
x86_64
        #elif TARGET_CPU_ARM
            #undef armv7
armv7
        #elif TARGET_CPU_ARM64
            #undef armv8
armv8
        #else
            #error Unsupported cpu
        #endif
    #elif TARGET_OS_MAC
        #if defined __x86_64__
            #undef x86_64
x86_64
        #elif defined __aarch64__
            #undef arm64
arm64
        #else
            #error Unsupported platform
        #endif
    #else
        #error Unsupported platform
    #endif
#elif defined __linux
    #ifdef __ANDROID__
        #ifdef __i386__
            #undef x86
x86
        #elif defined __arm__
            #undef armv7
armv7
        #elif defined __aarch64__
            #undef armv8
armv8
        #else
            #error Unsupported cpu
        #endif
    #else
        #ifdef __LP64__
            #undef x86_64
x86_64
        #else
            #undef x86
x86
        #endif
    #endif
#elif defined __EMSCRIPTEN__
    #undef wasm
wasm
#else
    #error Unsupported cpu
#endif
