project(selen)
cmake_minimum_required(VERSION 2.8)

set(CMAKE_CXX_FLAGS "-std=c++11 -g -Wall -O3")


#isa library
set(ISA_SRC "isa/src.cpp")
add_library(isa SHARED ${ISA_SRC})

#command line library: https://github.com/antirez/linenoise
set(LINENOISE_SRC linenoise/linenoise.c)
add_library(linenoise ${LINENOISE_SRC})

#simulator
set(SIM_SRC sim_main.cpp simulator.cpp application.cpp interactive.cpp)
add_executable(sim ${SIM_SRC})
target_link_libraries(sim isa pthread linenoise)

#disassembler
set(DISASM_SRC disas_main.cpp)
add_executable(disas ${DISASM_SRC})
target_link_libraries(disas isa)
