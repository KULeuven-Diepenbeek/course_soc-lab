---
title: 'FAQ'
chapter: true
weight: 900
draft: false
---

## Vivado generates verilog ip project

Go Tools in the top bar -> settings -> target language -> VHDL

## I updated my XSA, but it still doesn't work

Vitis versions newer then 2023.2 do not update the bitstream when you swap an xsa file.
<a href="https://adaptivesupport.amd.com/s/article/000036644?language=en_US"> https://adaptivesupport.amd.com/s/article/000036644?language=en_US

A workaround would be to export the bitstream file in Vivado and change the bitstream file path in Vitis.
In Vivado you can do file->export->export bitstream file.
Then in Vitis you can go to your application project press the gear icon next to run.
In that menu you can change the bitstream file, update it to the one you generated with Vivado.


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

## My Vitis doesn't work!

If you run Vitis 2024.2 on windows the buttons do not do anything by default

You can rename the vitis_hls name to fix this. We will not be doing HLS in this lab.

When Vitis is installed in the default directory:

C:\Xilinx\Vitis\2024.2: **Rename** .vitis_for_hls to .vitis_for_hls_XXXX

source: <a href="https://adaptivesupport.amd.com/s/question/0D54U00008sdgh7SAA/there-is-no-response-when-trying-to-create-platform-component-in-vitis-unified-ide-20242?language=en_US"> https://adaptivesupport.amd.com/s/question/0D54U00008sdgh7SAA/there-is-no-response-when-trying-to-create-platform-component-in-vitis-unified-ide-20242?language=en_US </a>


## My vitis keeps closing when I do CTRL+Z

Some of you might notice that Vitis closes when you do CTRL+Z on an AZERTY keyboard. This is because Vitis tries to be nice and maps your CTRL+Z to CTRL+W, CTRL+W is close window. To fix this ~~you buy a qwerty keyboard~~ you can change the settings.

File > Preferences > Open Settings (UI): Change keycode to code for Keyboard

{{% figure src="/img/faq/vitis_keyboard.png" title="Vitis keyboard fix" %}}
