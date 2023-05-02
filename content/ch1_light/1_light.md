---
title: 'Let there be light'
chapter: false
weight: 11
---


To get started you are going to build a hardware design that brings on the LEDs of the {{% pynq %}} board. The architecture is very simple and should look something link the image below.

## Describing the hardware
For the computer to understand what you are building, a Hardware Description Language (**HDL**) is required. In this lab, this will be **VHDL**. The environment that you are going to use to make the design is **Vivado**. This software suite, made available by **Xilinx** (the FPGA vendor), can be used for multiple purposes:

* hardware designing
* simulation of designs
* generation of hardware IP component
* running the FPGA toolchain
* insert/handle debugging features
* configuring the FPGA

#### Install the Vivado software
The Vivado software can be downloaded through the [Xilinx website](https://www.xilinx.com/support/download.html). You will need an account at the website, but you can make one for free. The software can be downloaded for free, but certainly isn't **free**. A license is required to enjoy all the features of the design suite, but The FPGA on the {{% pynq %}} is free to use. It is recommended to install Vivado 2020.2 or older. Make sure to install Vitis, because we will be using it during the labs. 

<!-- 
{{% notice note %}}
Contact the professor by mail to ask for a license. In this mail you need to provide: <br/>1) Which **OS** you are running, <br/>2) Whether you have a **32 or 64-bit** machine, and <br/>3) The **MAC address** of your networking interface.
{{% /notice %}}
-->

#### Install the {{% pynq %}} board drivers
Vivado is *board aware*. Alas, the {{% pynq %}} board is not by default known by the software. Additional metadata is to be added to your Xilinx Installation. To do this you need to download the board files from [here](https://www.tulembedded.com/FPGA/ProductsPYNQ-Z2.html). Later we also require the "Master XDC" file. You need to extract the board files archive in "<Xilinx installation directory>\Vivado\<version>\data\boards\board_files", if the directory doesn't exist you need to create it. After extracting you should have a folder called pynq-z2 inside the board_files directory. For old Vivado versions you can follow the instructions [here](https://pynq.readthedocs.io/en/v2.5.1/overlay_design_methodology/board_settings.html?highlight=board#vivado-board-files). Note that the download links are dead.

## Example project
Let us start with a very simple example project. These {{% pynq %}} boards have LEDs and pushbuttons. We want to use a push button to turn on the LED. One thing is that we want to do this **Synchronusly**. This means that LED lights up if the pushbutton is pressed and a rising edge of a clock comes in. It turns back off when the pushbutton is not pressed and there is again a rising edge. In practice we will not see this delay, because our clock is 125MHz.

{{% figure src="/img/ch1/First_demo.png" title="Schematic of example project" %}}

How do you code this? First you will create a VHDL design source in Vivado, then you see it gives a nice template to write your beautiful code. It is expected that you already know the basics of VHDL from previous year(s). Here is the example code of this schematic. Be happy with the code below, because this is one of the only times you will get example **design** code during this course.

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity example_project is
  Port (clock: in STD_LOGIC;
        pushbutton: in STD_LOGIC;
        LED: out STD_LOGIC );
end example_project;

architecture Behavioral of example_project is

begin

SEQ: process(clock) begin

    if rising_edge(clock) then -- clock'event and clock = '1' is the same as rising_edge(clock)
        LED <= pushbutton;
    end if;

end process;

end Behavioral;
```

Now you try to understand this code. It creates a process called SEQ, which has an if statement that defines that when there is a rising edge of the clock the pushbutton should be read and the output should be put on the LED. Note that this if statement does not include an else statement because it needs to remember the value until the next rising edge of the clock.

## From RTL design to bitstream
The example above is very simple. The design holds nothing more that a 1-bit register. Making a drawing of the architecture is not really required. **PROTIP:** If designs get more complex, actually *making* this type of drawings like the one above, helps enormously !! 

Once you *described* your design in VHDL the FPGA toolchain can run **synthesis**. During this part a *netlist* is generated of your design. The netlist is one input for the next step.

The second part that is required is a "how-do-I-map-this-to-the-outside-world" file. Your netlist has toplevel ports (inputs and outputs). For FPGA design with Xilinx tools, the mapping of these ports to physical pins is done through a **constraint** file. The extension of these files is: **.xdc** (Xilinx Design Constraint). Another important aspect that is covert by the xdc-file is constraints on timing. An example is shown below.

```tcl
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { clock }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clock}];

set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { LED }]; #IO_L6N_T0_VREF_34 Sch=led[0]

set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { pushbutton }]; #IO_L4P_T0_35 Sch=btn[0]

```

The first line in the example above maps the **sysclk** port to pin **H16** of the FPGA. The IO standard is **LVCMOS33**. The second line creates an internal clock signal on port **sysclk**. The name is *sys_clk_pin* and it has a 125 MHz frequency with a 50% duty cycle.

The third line of code maps pin **R14** to the LED pin of the design. While the fourth one maps pin **D19** to the pushbutton pin. Both are of the IOSTANDARD LVCMOS33, which means that it is using 3.3V logic.

An example xdc file for the {{% pynq %}} can be found [here](https://dpoauwgwqsy2x.cloudfront.net/Download/pynq-z2_v1.0.xdc.zip)

#### Do it yourself
Now that you have an example, let's start with an easy exercise. This is just to refresh your memory and your VHDL.

Describe the design depicted below in VHDL. In the first iteration you can simply ignore everything in <span style="color: green; font-weight: bold">green</span>. Although there are only 2 DIP switches, there are 4 LEDS. Just repeat both bits twice to form a 4 bit register.
{{% figure src="/img/ch1/ex1.png" title="The architecture for the exercises" %}}

{{% notice note %}}
One single bit is ... well ... a **bit**. Eight bits is a **byte** and four bits is a **nibble**. 
<br/><br/>
If you group 1024 bits, this is called a **kibibit**. Yes !! That is the correct name according to the International Electrotechnical Commission (IEC). A **kilobit** is 1000 bits.
{{% /notice %}}

When this works, *surprise* *surprise*, add the part in <span style="color: green; font-weight: bold">green</span>. Through the use of a pushbutton you should be able to switch between the inverted and the non-inverted nibble.

The result should look something like this:
<div class="multicolumn">
  <div class="column">
    <h4>Exercise 1</h4>
    {{< youtube id="F3R_t2dk5Vk?rel=0" >}}
  </div>
  <div class="column">
    <h4>Exercise 2</h4>
    {{< youtube id="EiXlhPJy_hA?rel=0" >}}
  </div>
</div>

#### Exercise 3

Now we are going to use the pushbuttons to turn on the LEDs. If you press a pushbutton the corresponding LED needs to be toggle. If it is off it needs to turn on until the pushbutton is pressed again. You need to detect the **rising** edge of the pushbutton input.
 
<div style="width:49%">
{{< youtube id="nBQ-mKoYKKQ?rel=0" >}}
</div>

{{% notice warning %}}
Don't use the pushbutton as the clock input of a flip-flop. The flip-flop clock input is always reserved for a clock. The FPGA has dedicated routing internally for the clock.
{{% /notice %}}


