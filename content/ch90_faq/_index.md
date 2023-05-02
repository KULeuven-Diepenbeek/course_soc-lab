---
title: 'FAQ'
chapter: true
weight: 900
draft: false
---

## Vivado generates verilog ip project

Go Tools in the top bar -> settings -> target language -> VHDL

## Vitis makefile error

This is a makefile error issue specifically to Vivado 2020.1 or newer on a windows system. There are multiple options to solve this issue. The easiest one is to use a different Vivado/Vitis option, but that takes a lot of time to reinstall.

### fixing the makefile

This makefile gets generated when **packaging** the AXI4 ip core. We fix this after the IP core is packaged.

You can copy the content of the makefile below or <a href="files/makefile_vitis/Makefile" download> download </a> it and replace it.

The file is located in the folder where you ip project is located. For our xmas light the Makefile is located in "xmas_light_ip\xmas_light_1.0\drivers\xmas_light_v1_0\src".

```
COMPILER=
ARCHIVER=
CP=cp
COMPILER_FLAGS=
EXTRA_COMPILER_FLAGS=
LIB=libxil.a

RELEASEDIR=../../../lib
INCLUDEDIR=../../../include
INCLUDES=-I./. -I${INCLUDEDIR}

INCLUDEFILES=*.h
LIBSOURCES=$(wildcard *.c)
OBJS=$(addsuffix .o, $(basename $(wildcard *.c)))

libs:
	echo "Compiling xmas_light..."
	$(COMPILER) $(COMPILER_FLAGS) $(EXTRA_COMPILER_FLAGS) $(INCLUDES) $(LIBSOURCES)
	$(ARCHIVER) -r ${RELEASEDIR}/${LIB} ${OBJS}
	make clean

include:
	${CP} $(INCLUDEFILES) $(INCLUDEDIR)

clean:
	rm -rf ${OBJECTS} ${ASSEMBLY_OBJECTS}

```

You can read more on <a href="https://support.xilinx.com/s/article/75527?language=en_US"> https://support.xilinx.com/s/article/75527?language=en_US </a>