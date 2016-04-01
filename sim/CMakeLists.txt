project(selen)
cmake_minimum_required(VERSION 2.8)

set(CMAKE_CXX_FLAGS "-std=c++11 -g -Wall -O3")

#model library
aux_source_directory(model/ MODEL_LIB_SRC)
add_library(model SHARED ${MODEL_LIB_SRC})

#command line library: https://github.com/antirez/linenoise
set(LINENOISE_SRC linenoise/linenoise.c)
add_library(linenoise ${LINENOISE_SRC})

#simulator
set(SIM_SRC main.cpp application.cpp interactive.cpp)
add_executable(sim ${SIM_SRC})
target_link_libraries(sim model linenoise)

#sv-dpi library
set(DPI_LIB_SRC dpi/core_model_dpi.cpp )
add_library(modeldpi SHARED ${DPI_LIB_SRC} ${MODEL_LIB_SRC})

#dpi iface test
set(DPI_TEST dpi/test.c)
add_executable(dpitest ${DPI_TEST})
target_link_libraries(dpitest modeldpi)
