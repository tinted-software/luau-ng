cmake_minimum_required(VERSION 4.0)

set(CMAKE_DISABLE_IN_SOURCE_BUILDS ON)
set(CMAKE_DISABLE_SOURCE_CHANGES ON)

project(luau-ng LANGUAGES CXX C VERSION 0.1.0)

option(LUAU_BUILD_CLI "Build CLI" ON)
option(LUAU_BUILD_TESTS "Build tests" ON)
option(LUAU_BUILD_WEB "Build Web module" OFF)
option(LUAU_ENABLE_LTO "Enable link time optimization" OFF)
option(LUAU_ENABLE_WERROR "Warnings as errors" OFF)
option(LUAU_ENABLE_CLANG_TIDY "Use clang-tidy" OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(LUAU_ENABLE_CLANG_TIDY)
    set(CMAKE_CXX_CLANG_TIDY "clang-tidy")
endif()

if(LUAU_ENABLE_LTO)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
endif()

add_library(Luau.Compiler)
add_library(Luau.CLI.lib)
add_library(Luau.Config)
add_library(Luau.Ast)
add_library(Luau.Analysis)
add_library(Luau.EqSat)
add_library(Luau.CodeGen)
add_library(Luau.VM)
add_library(Luau.Require)
add_library(Luau.RequireNavigator)
add_library(Luau.Common INTERFACE)
add_library(isocline)

if(LUAU_BUILD_CLI)
    add_executable(Luau.Repl.CLI)
    add_executable(Luau.Analyze.CLI)
    add_executable(Luau.Ast.CLI)
    add_executable(Luau.Reduce.CLI)
    add_executable(Luau.Compile.CLI)
    add_executable(Luau.Bytecode.CLI)

    # This also adds target `name` on Linux/macOS and `name.exe` on Windows
    set_target_properties(Luau.Repl.CLI PROPERTIES OUTPUT_NAME luau)
    set_target_properties(Luau.Analyze.CLI PROPERTIES OUTPUT_NAME luau-analyze)
    set_target_properties(Luau.Ast.CLI PROPERTIES OUTPUT_NAME luau-ast)
    set_target_properties(Luau.Reduce.CLI PROPERTIES OUTPUT_NAME luau-reduce)
    set_target_properties(Luau.Compile.CLI PROPERTIES OUTPUT_NAME luau-compile)
    set_target_properties(Luau.Bytecode.CLI PROPERTIES OUTPUT_NAME luau-bytecode)
endif()

if(LUAU_BUILD_TESTS)
    enable_testing()
    add_executable(Luau.UnitTest)
    add_executable(Luau.Conformance)
endif()

if(LUAU_BUILD_WEB)
    add_executable(Luau.Web)
endif()

# Proxy target to make it possible to depend on private VM headers
add_library(Luau.VM.Internals INTERFACE)

include(GNUInstallDirs)
include(Sources.cmake)

target_include_directories(Luau.Common INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Common/include>
    $<INSTALL_INTERFACE:include>
)
install(TARGETS Luau.Common EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Common/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

target_compile_features(Luau.CLI.lib PUBLIC cxx_std_26)
target_link_libraries(Luau.CLI.lib PRIVATE Luau.Common Luau.Config)
target_include_directories(Luau.CLI.lib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/CLI/include>
    $<INSTALL_INTERFACE:include>
)
target_compile_features(Luau.Ast PUBLIC cxx_std_26)
install(TARGETS Luau.CLI.lib EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/CLI/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

target_compile_features(Luau.Ast PUBLIC cxx_std_26)
target_include_directories(Luau.Ast PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Ast/include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(Luau.Ast PUBLIC Luau.Common)
install(TARGETS Luau.Ast EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Ast/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

target_compile_features(Luau.Compiler PUBLIC cxx_std_26)
target_include_directories(Luau.Compiler PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Compiler/include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(Luau.Compiler PUBLIC Luau.Ast)
install(TARGETS Luau.Compiler EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Compiler/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

target_compile_features(Luau.Config PUBLIC cxx_std_26)
target_include_directories(Luau.Config PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Config/include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(Luau.Config PUBLIC Luau.Ast)
install(TARGETS Luau.Config EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Config/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)
target_link_libraries(Luau.Config PRIVATE Luau.Compiler Luau.VM)

target_compile_features(Luau.Analysis PUBLIC cxx_std_26)
target_include_directories(Luau.Analysis PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Analysis/include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(Luau.Analysis PUBLIC Luau.Ast Luau.EqSat Luau.Config)
target_link_libraries(Luau.Analysis PRIVATE Luau.Compiler Luau.VM)
install(TARGETS Luau.Analysis EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Analysis/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

target_compile_features(Luau.EqSat PUBLIC cxx_std_26)
target_include_directories(Luau.EqSat PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/EqSat/include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(Luau.EqSat PUBLIC Luau.Common)
install(TARGETS Luau.EqSat EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/EqSat/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

target_compile_features(Luau.CodeGen PRIVATE cxx_std_26)
target_include_directories(Luau.CodeGen PUBLIC CodeGen/include)
target_link_libraries(Luau.CodeGen PRIVATE Luau.VM Luau.VM.Internals) # Code generation needs VM internals
target_link_libraries(Luau.CodeGen PUBLIC Luau.Common)
target_include_directories(Luau.CodeGen PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/CodeGen/include>
    $<INSTALL_INTERFACE:include>
)
install(TARGETS Luau.CodeGen EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/CodeGen/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

target_compile_features(Luau.VM PRIVATE cxx_std_11)
target_include_directories(Luau.VM PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/VM/include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(Luau.VM PUBLIC Luau.Common)
install(TARGETS Luau.VM EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/VM/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

target_compile_features(Luau.Require PUBLIC cxx_std_26)
target_include_directories(Luau.Require PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Require/Runtime/include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(Luau.Require PUBLIC Luau.VM)
target_link_libraries(Luau.Require PRIVATE Luau.RequireNavigator)
install(TARGETS Luau.Require EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Require/Runtime/include
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

target_compile_features(Luau.RequireNavigator PUBLIC cxx_std_26)
target_include_directories(Luau.RequireNavigator PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Require/Navigator/include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(Luau.RequireNavigator PUBLIC Luau.Config)
install(TARGETS Luau.RequireNavigator EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Require/Navigator/include
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

target_include_directories(isocline PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/extern/isocline/include>
    $<INSTALL_INTERFACE:include>
)
install(TARGETS isocline EXPORT LuauTargets)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/extern/isocline/include
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

target_include_directories(Luau.VM.Internals INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/VM/src>
    # no INSTALL_INTERFACE: the `Internals` target really only exists at compile-time
)
install(TARGETS Luau.VM.Internals EXPORT LuauTargets)


set(LUAU_OPTIONS)

if(MSVC)
    list(APPEND LUAU_OPTIONS /D_CRT_SECURE_NO_WARNINGS) # We need to use the portable CRT functions.
    list(APPEND LUAU_OPTIONS "/we4018") # Signed/unsigned mismatch
    list(APPEND LUAU_OPTIONS "/we4388") # Also signed/unsigned mismatch
else()
    list(APPEND LUAU_OPTIONS -Wall) # All warnings
    list(APPEND LUAU_OPTIONS -Wimplicit-fallthrough)
    list(APPEND LUAU_OPTIONS -Wsign-compare) # This looks to be included in -Wall for GCC but not clang
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    list(APPEND LUAU_OPTIONS /MP) # Distribute single project compilation across multiple cores
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # Some gcc versions treat var in `if (type var = val)` as unused
    # Some gcc versions treat variables used in constexpr if blocks as unused
    list(APPEND LUAU_OPTIONS -Wno-unused)
    # some gcc versions warn maybe uninitialized on optional<string> members on structs
    list(APPEND LUAU_OPTIONS -Wno-maybe-uninitialized)
endif()

# Enabled in CI; we should be warning free on our main compiler versions but don't guarantee being warning free everywhere
if(LUAU_WERROR)
    if(MSVC)
        list(APPEND LUAU_OPTIONS /WX) # Warnings are errors
    else()
        list(APPEND LUAU_OPTIONS -Werror) # Warnings are errors
    endif()
endif()

if(LUAU_BUILD_WEB)
    # add -fexceptions for emscripten to allow exceptions to be caught in C++
    list(APPEND LUAU_OPTIONS -fexceptions)
endif()

set(ISOCLINE_OPTIONS)

if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    list(APPEND ISOCLINE_OPTIONS -Wno-unused-function)
endif()

target_compile_options(Luau.Ast PRIVATE ${LUAU_OPTIONS})
target_compile_options(Luau.Analysis PRIVATE ${LUAU_OPTIONS})
target_compile_options(Luau.EqSat PRIVATE ${LUAU_OPTIONS})
target_compile_options(Luau.CLI.lib PRIVATE ${LUAU_OPTIONS})
target_compile_options(Luau.CodeGen PRIVATE ${LUAU_OPTIONS})
target_compile_options(Luau.VM PRIVATE ${LUAU_OPTIONS})
target_compile_options(isocline PRIVATE ${LUAU_OPTIONS} ${ISOCLINE_OPTIONS})

if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND MSVC_VERSION GREATER_EQUAL 1924)
    # disable partial redundancy elimination which regresses interpreter codegen substantially in VS2022:
    # https://developercommunity.visualstudio.com/t/performance-regression-on-a-complex-interpreter-lo/1631863
    set_source_files_properties(VM/src/lvmexecute.cpp PROPERTIES COMPILE_FLAGS /d2ssa-pre-)
endif()

if (NOT MSVC)
    # disable support for math_errno which allows compilers to lower sqrt() into a single CPU instruction
    target_compile_options(Luau.VM PRIVATE -fno-math-errno)
endif()

if(MSVC AND LUAU_BUILD_CLI)
    # the default stack size that MSVC linker uses is 1 MB; we need more stack space in Debug because stack frames are larger
    set_target_properties(Luau.Analyze.CLI PROPERTIES LINK_FLAGS_DEBUG /STACK:2097152)
    set_target_properties(Luau.Repl.CLI PROPERTIES LINK_FLAGS_DEBUG /STACK:2097152)
endif()

# embed .natvis inside the library debug information
if(MSVC)
    target_link_options(Luau.Ast INTERFACE /NATVIS:${CMAKE_CURRENT_SOURCE_DIR}/tools/natvis/Ast.natvis)
    target_link_options(Luau.Analysis INTERFACE /NATVIS:${CMAKE_CURRENT_SOURCE_DIR}/tools/natvis/Analysis.natvis)
    target_link_options(Luau.CodeGen INTERFACE /NATVIS:${CMAKE_CURRENT_SOURCE_DIR}/tools/natvis/CodeGen.natvis)
    target_link_options(Luau.VM INTERFACE /NATVIS:${CMAKE_CURRENT_SOURCE_DIR}/tools/natvis/VM.natvis)
endif()

# make .natvis visible inside the solution
if(MSVC_IDE)
    target_sources(Luau.Ast PRIVATE tools/natvis/Ast.natvis)
    target_sources(Luau.Analysis PRIVATE tools/natvis/Analysis.natvis)
    target_sources(Luau.CodeGen PRIVATE tools/natvis/CodeGen.natvis)
    target_sources(Luau.VM PRIVATE tools/natvis/VM.natvis)
endif()

# On Windows and Android threads are provided, on Linux/Mac/iOS we use pthreads
add_library(osthreads INTERFACE)
if(CMAKE_SYSTEM_NAME MATCHES "Linux|Darwin|iOS")
    target_link_libraries(osthreads INTERFACE "-lpthread")
endif ()

if(LUAU_BUILD_CLI)
    target_compile_options(Luau.Repl.CLI PRIVATE ${LUAU_OPTIONS})
    target_compile_options(Luau.Reduce.CLI PRIVATE ${LUAU_OPTIONS})
    target_compile_options(Luau.Analyze.CLI PRIVATE ${LUAU_OPTIONS})
    target_compile_options(Luau.Ast.CLI PRIVATE ${LUAU_OPTIONS})
    target_compile_options(Luau.Compile.CLI PRIVATE ${LUAU_OPTIONS})
    target_compile_options(Luau.Bytecode.CLI PRIVATE ${LUAU_OPTIONS})

    target_include_directories(Luau.Repl.CLI PRIVATE extern extern/isocline/include)

    target_link_libraries(Luau.Repl.CLI PRIVATE Luau.Compiler Luau.Config Luau.CodeGen Luau.VM Luau.Require Luau.CLI.lib isocline)

    target_link_libraries(Luau.Repl.CLI PRIVATE osthreads)
    target_link_libraries(Luau.Analyze.CLI PRIVATE osthreads)

    target_link_libraries(Luau.Analyze.CLI PRIVATE Luau.Analysis Luau.CLI.lib Luau.RequireNavigator)

    target_link_libraries(Luau.Ast.CLI PRIVATE Luau.Ast Luau.Analysis Luau.CLI.lib)

    target_compile_features(Luau.Reduce.CLI PRIVATE cxx_std_26)
    target_include_directories(Luau.Reduce.CLI PUBLIC Reduce/include)
    target_link_libraries(Luau.Reduce.CLI PRIVATE Luau.Common Luau.Ast Luau.Analysis Luau.CLI.lib)

    target_link_libraries(Luau.Compile.CLI PRIVATE Luau.Compiler Luau.VM Luau.CodeGen Luau.CLI.lib)

    target_link_libraries(Luau.Bytecode.CLI PRIVATE Luau.Compiler Luau.VM Luau.CodeGen Luau.CLI.lib)
endif()

if(LUAU_BUILD_TESTS)
    find_package(doctest REQUIRED)
    get_target_property(DOCTEST_INCLUDE_DIR doctest::doctest INTERFACE_INCLUDE_DIRECTORIES)

    target_compile_options(Luau.UnitTest PRIVATE ${LUAU_OPTIONS})
    target_compile_definitions(Luau.UnitTest PRIVATE DOCTEST_CONFIG_DOUBLE_STRINGIFY)
    target_link_libraries(Luau.UnitTest PRIVATE Luau.Analysis Luau.Compiler Luau.CodeGen Luau.VM doctest::doctest)
    target_include_directories(Luau.UnitTest PRIVATE ${DOCTEST_INCLUDE_DIR}/doctest)

    target_compile_options(Luau.Conformance PRIVATE ${LUAU_OPTIONS})
    target_compile_definitions(Luau.Conformance PRIVATE DOCTEST_CONFIG_DOUBLE_STRINGIFY)
    target_link_libraries(Luau.Conformance PRIVATE Luau.Analysis Luau.Compiler Luau.CodeGen Luau.VM doctest::doctest)
    target_include_directories(Luau.Conformance PRIVATE ${DOCTEST_INCLUDE_DIR}/doctest)
    file(REAL_PATH "tests/conformance" LUAU_CONFORMANCE_SOURCE_DIR)

    add_test(NAME luau-unittests COMMAND Luau.UnitTest)
    add_test(NAME luau-conformance COMMAND Luau.Conformance)
endif()

if(LUAU_BUILD_WEB)
    target_compile_options(Luau.Web PRIVATE ${LUAU_OPTIONS})
    target_link_libraries(Luau.Web PRIVATE Luau.Compiler Luau.VM)

    # declare exported functions to emscripten
    target_link_options(Luau.Web PRIVATE -sEXPORTED_FUNCTIONS=['_executeScript'] -sEXPORTED_RUNTIME_METHODS=['ccall','cwrap'])

    # add -fexceptions for emscripten to allow exceptions to be caught in C++
    target_link_options(Luau.Web PRIVATE -fexceptions)

    # the output is a single .js file with an embedded wasm blob
    target_link_options(Luau.Web PRIVATE -sSINGLE_FILE=1)
endif()

# validate dependencies for internal libraries
foreach(LIB Luau.Ast Luau.Compiler Luau.Config Luau.Analysis Luau.EqSat Luau.CodeGen Luau.VM)
    if(TARGET ${LIB})
        get_target_property(DEPENDS ${LIB} LINK_LIBRARIES)
        if(LIB MATCHES "CodeGen|VM" AND DEPENDS MATCHES "Ast|Analysis|Config|Compiler")
            message(FATAL_ERROR ${LIB} " is a runtime component but it depends on one of the offline components")
        endif()
        if(LIB MATCHES "Ast|EqSat|Compiler" AND DEPENDS MATCHES "CodeGen|VM")
            message(FATAL_ERROR ${LIB} " is an offline component but it depends on one of the runtime components")
        endif()
        if(LIB MATCHES "Ast|Compiler" AND DEPENDS MATCHES "Analysis|Config")
            message(FATAL_ERROR ${LIB} " is a compiler component but it depends on one of the analysis components")
        endif()
    endif()
endforeach()

cmake_path(APPEND libdir_for_pc_file "\${prefix}" "${CMAKE_INSTALL_LIBDIR}")
cmake_path(APPEND includedir_for_pc_file "\${prefix}" "${CMAKE_INSTALL_INCLUDEDIR}")

file(RELATIVE_PATH in_file ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/tools/luau.pc.in)
string(REPLACE ".in" "" pc_file ${in_file})
configure_file(${in_file} ${CMAKE_CURRENT_BINARY_DIR}/${pc_file} @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${pc_file} DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)

if(LUAU_BUILD_CLI)
    install(
        TARGETS
        Luau.Repl.CLI
        Luau.Reduce.CLI
        Luau.Analyze.CLI
        Luau.Ast.CLI
        Luau.Compile.CLI
        Luau.Bytecode.CLI
    )
endif()
