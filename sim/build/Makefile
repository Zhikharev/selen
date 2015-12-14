GCC_PREFIX=/usr/bin/

GCC_FLAGS += -std=c++11 -g -Wall -O3

#
ISA_DIR=../isa
ISA_SRC=../isa/src.cpp 
SIMULATOR_CLASS_SRC= ../simulator.cpp
DISAS_SRC=../disas_main.cpp
SIM_SRC=../sim_main.cpp

all: build

isa.o: $(ISA_SRC)
	$(GCC_PREFIX)g++ -fPIC -rdynamic -I$(ISA_DIR) $(GCC_FLAGS) -c $(ISA_SRC) -o isa.o

libisa.so : ./isa.o
	$(GCC_PREFIX)g++ -fPIC -rdynamic $(GCC_FLAGS) -shared -o libisa.so isa.o

simulator.o : $(SIMULATOR_CLASS_SRC)
	$(GCC_PREFIX)g++ -I$(ISA_DIR) $(GCC_FLAGS) -fPIC -L./ -lisa -o simulator.o -c $(SIMULATOR_CLASS_SRC)
	
sim: ./libisa.so ./simulator.o $(SIM_SRC)
	$(GCC_PREFIX)g++ -I$(ISA_DIR) $(GCC_FLAGS) -L./  ./simulator.o -lisa -o sim $(SIM_SRC)

disas: ./libisa.so $(DISAS_SRC)
	$(GCC_PREFIX)g++ -I$(ISA_DIR) $(GCC_FLAGS) -L./ ./simulator.o -lisa -o disas $(DISAS_SRC)

build: ./libisa.so ./sim ./disas


.PHONY: clean
clean:
	rm   ./*.o ./*.so ./disas ./sim 


