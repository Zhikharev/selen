project(selen)
cmake_minimum_required(VERSION 2.8)

set(CMAKE_CXX_FLAGS "-std=c++11 -g -Wall -O3")


#isa library
aux_source_directory(isa/ ISA_SRC)
add_library(isa SHARED ${ISA_SRC})

#command line library: https://github.com/antirez/linenoise
set(LINENOISE_SRC linenoise/linenoise.c)
add_library(linenoise ${LINENOISE_SRC})

#simulator
set(SIM_SRC sim_main.cpp simulator.cpp application.cpp interactive.cpp)
add_executable(sim ${SIM_SRC})
target_link_libraries(sim isa linenoise)

#sv-dpi library prototype
aux_source_directory(dpi/ DPI_LIB)

add_library(selenisasimdpi SHARED ${DPI_LIB} ${ISA_SRC})
