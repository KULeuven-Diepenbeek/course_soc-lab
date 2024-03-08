---
title: 'Put a SoC in it'
chapter: false
weight: 21
draft: false
---

Today's designs often feature a System-on-Chip (SOC). This is a buzz word which means that a chip contains more than only a processing core. Typically there are more components like, for example: a timer, some memory, and a UART. 

The {{% pynq %}} board contains a ZYNQ FPGA. This type of FPGAs is a hybrid form which combines the traditional reconfigurable fabric of an FPGA, with a dedicated processor. In the case of the {{% pynq %}} the dedicated processor is an ARM Cortex A9.

## Hardware

In the next step, we're going to make a SOC. By the time it is finished it will look like the image below: 

<div class="multicolumn">
  <div class="column">
{{% figure src="/img/ch2/soc.png" title="The targeted SOC" %}}
  </div>
  <div class="column">
    <ul>
      <li><span style="color: #B85450; font-weight: bold">processor</span>: the built-in ARM Cortex A9</li>
      <li><span style="color: #D79B00; font-weight: bold">DDR</span>: the DDR3 Flash Memory, off-chip on the PCB</li>
      <li><span style="color: #D6B656; font-weight: bold">reset</span>: reset generation (and synchronisation)</li>
      <li><span style="color: #82B366; font-weight: bold">AXI4</span>: the AXI4 on-chip bus</li>
      <li><span style="color: #6C8EBF; font-weight: bold">xmas_light</span>: the IP core that drives the LEDs and the RGB LEDs.</li>
      <li><span style="color: #6C8EBF; font-weight: bold">communication</span>: the IP core that receives and sends instructions</li>       
    </ul>
  </div>
</div>


The different components of the SOC have to be connected to each other. This is done through an on-chip bus. A heavily used interface is the **Advanced eXtensible Interface (AXI)**, which originates from ARM. The current version is AXI5, which has some minor additions to AXI4. We will make use of **AXI4** during the labs. More information on AXI can be found online, starting from [wikipedia](https://en.wikipedia.org/wiki/Advanced_eXtensible_Interface).

### IP component

Up until now, you've been working on the (hardware) functionality of the *fancy lights*. To attach your design to an AXI bus (or any other bus), the component needs a certain interface. The details on this interface itself fall out-of-scope for this lab. The Vivado design tool has a wizard that guides you through the generation of an AXI4 component. Using this wizard, the design as shown below is generated.

{{% figure src="/img/ch2/ipcore.jpg" title="The generated IP core" %}}

The entity or module that you have been working on is the **xmas_light** block in the middle. The outer most module **xmas_light_v1_0** does not do anything other than forwarding the top level inputs and outputs to **xmas_light_v1_0_S00_AXI**. 

From the naming of this middle block you can tell: 1) it is a child of xmas_light_v1_0, 2) it provides an AXI interface, and 3) the interface is *slave 0*. If the IP component has multiple interfaces, these numbers and names change.

Your IP component will be reachable by the processor through an address. This is called **Memory-Mapped IO (MMIO)**. The interface that is generated already provides a number of **slave register** in xmas_light_v1_0_S00_AXI. When the processor read from (or writes to) a certain address, these operations actually target these registers. It is up to you (the designer) **how** you will wire up these registers to your design.

For example: the 32-bit slave register 0 will be connected to the **command** input. The LSB of slave register 1 will be connected to thte **command valid**.

<!--
{{< youtube id="B-F_jVeAcfs?rel=0" >}}
-->

{{% notice warning %}}
Make sure you have **tested** your design in the testbench before continuing.
{{% /notice %}}

<div class="multicolumn">
  <div class="column">
The goal is to create an <b>AXI4 IP</b> of the xmas light design you have already made and tested. One approach would be to look up the specifications of AXI4 and start implementing the protocol. The documentation is freely availble online, but this is out-of-scope for this lab.
<br>
Luckily Xilinx provides tools to create an AXI4 IP more easily. By going to <b>tools->Create and package new IP</b> you can create a new AXI4 IP.


</div>
  <div class="column">

{{% figure src="/img/ch2/create_package_new_ip.png" title="Create and package new IP" %}}

  </div>
</div>

You start by pressing next and in the next box you say "Create a new AXI4 peripheral".


{{% figure src="/img/ch2/create_AXI4.png" title="Create AXI4 peripheral" %}}


In the details you give it a name and you can also give it a description.

{{% notice note %}}
Do not forget to change the **IP Location** or at note down where it is saved!
{{% /notice %}}


{{% figure src="/img/ch2/peripheral_details.png" title="Peripheral details" %}}

<div class="multicolumn">
  <div class="column">
{{% md %}}

Here we can change the interfaces. You can add and remove AXI interfaces to create IPs with multiple interfaces. For our lab <b>1 AXI interface</b> is enough.

For each interface we can configure the protocol. There is the chose between Lite, Full and Stream. We will use the <b>Lite</b> interface type.

Then there is the interface mode. Were we can chose between Slave and Master. For our project the <b>ARM CPU</b> will be the <b>master</b>, so then <b>our IP</b> needs to be the <b>slave</b>.

The data width for AXI4 Lite is always 32-bits, so we can't change this option.

Memory size is only for full AXI4 and we are creating a AXI4 Lite IP.

The <b>number of registers</b> is important. Here we need to think **which inputs and outputs** needs to come and go to the CPU?

If we look at the entity we see this


```vhdl
entity xmas_light is
  port (
    reset : in STD_LOGIC;
    clock : in STD_LOGIC;
    command : in STD_LOGIC_VECTOR(31 downto 0);
    command_valid : in STD_LOGIC;
    RGB0 : out STD_LOGIC_VECTOR(2 downto 0);
    RGB1 : out STD_LOGIC_VECTOR(2 downto 0);
    LEDs : out STD_LOGIC_VECTOR(3 downto 0)
  );
end xmas_light;
```

Which of those signals do we get from the register/CPU?

* **reset**: this is a **global** signals which we get from the IP
* **clock**: the **IP is clocked** and we use this same clock, we can later configure the clock speed of this clock
* **command**: this is the **command that drives the XMAS lights**
* **commmand_valid**: this indicates if **when we can read** this command
* **RGB0**: This is the **output** to RGB led 0
* **RGB1**: This is the **output** to RGB led 1
* **Leds**: This is the **output** to LEDs

**Reset** and **clock** are **global** signals.

The **CPU** needs to **supply** the **command** and the **command_valid** signals.

The **outputs** needs to be **added to the IP I/O** ports!

So we only need registers for the **32-bit command** signal and the **command_valid** signal. This means that **2 registers** are sufficient. Vivado tells us that the **minimum is 4**, so we will use 4 registers.

{{% /md %}}

</div>
  <div class="column">
{{% figure src="/img/ch2/add_interface.png" title="Create and package new IP" %}}
  </div>
</div>

At the last page we say we want to **edit the IP**.

{{% figure src="/img/ch2/edit_ip.png" title="Create peripheral" %}}

Now it generates the template code for a AXI4 light IP block. 

<div class="multicolumn">
  <div class="column">
{{% md %}}

Vivado has a *nice* feature to save storage space when you create a lot of IP blocks. When you made your IP and closes the project it will decide that you're finished with it and do not want to change it again, so it will decide to remove the project file to change the IP. This is very frustrating when you want to make changes later, because you will have to create the new IP from scratch.

Luckily we can disable this feature by clicking on settings on the left and under IP->Packager ticking the box "delete project after packaging" off.

{{% notice note %}}
When creating a new IP later, verify if the setting is still turned off!
{{% /notice %}}

{{% /md %}}

</div>
  <div class="column">

{{% figure src="/img/ch2/delete_project_after_packaging.png" title="Delete project packager setting" %}}

  </div>
</div>

Now we have a project with 2 files. For me they are called "xmas_light_v1_0" and "xmas_light_v1_0_S00_AXI". Here we will need to add our XMAS light somehow. xmas_light_v1_0_S00_AXI is the main file and xmas_light_v1_0 is just a small wrapper.

{{% notice note %}}
If your **IP** is **in Verilog** instead of VHDL you can go to the **settings** and changed under general change the **target language** from verilog to **VHDL**.
{{% /notice %}}

Some things to note in the generated code before inserting our design. 

* There are 4 registers (as configured) called slv_reg0..3.
* There is a clock called S_AXI_ACLK
* There is a **active low reset** called S_AXI_ARESETN
* The code **writes** to **the registers** by default, if your design writes to one of these registers. If your design writes to registers, you need to **make sure** there are **no double drivers** and remove the code which writes to them.

At the **bottom of the file** xmas_light_v1_0_S00_AXI you have a section where they tell you to add your code. So that is where we will put our design.
But first **add the sources**, you can use add files and select the files from the other project. I recommend you thick the box **copy sources into IP directory** to make sure you copy the files to this project.

```vhdl
	-- Add user logic here

	-- User logic ends
```

Now we need to think how we want to map the I/O of our design to the registers. We will use slv_reg0 as our command registers and use the first bit of slv_reg1 as the command_valid signal.

Note that the our designs expects an **active high reset** so we need to invert the reset signal.

```vhdl
	-- Add user logic here
	reset_i <= not(S_AXI_ARESETN);
    xmas_light_inst00: component xmas_light port map (
    reset => reset_i,
    clock => S_AXI_ACLK,
    command => slv_reg0,
    command_valid => slv_reg1(0),
    RGB0 => RGB0,
    RGB1 => RGB1,
    LEDs => LEDs
  );
	-- User logic ends
```

Of course if we **instantiate a component and use a signal** we also have to **add** this to the **architecture**.

And if we use output ports it also has to be added to entity declaration, Xilinx again give us a spot to add those.

```vhdl
		-- Users to add ports here
            RGB0 : out STD_LOGIC_VECTOR(2 downto 0);
            RGB1 : out STD_LOGIC_VECTOR(2 downto 0);
            LEDs : out STD_LOGIC_VECTOR(3 downto 0);
		-- User ports ends
```

Now we also need to add these port to the other file **xmas_light_v1_0**. Here you need to **add** these to the **entity**, the **component** declaration and the **port map**. 

{{% notice note %}}
Don't forget to **note down** the connections to the registers; and to **wire out** external signals all the way up !!!
{{% /notice %}}

Now we have all code in the IP and need to package it so it can be used in an other project.

On the left we press **Edit packaged IP**. Here we see all the packaging steps.

In all of the packaging steps where there is not a green check mark you press **merge changes from ...**.

{{% figure src="/img/ch2/package_ip_merge.png" title="merge changes" %}}

When do you can press the **Re-package** IP button!

{{% figure src="/img/ch2/repackage_ip.png" title="re-package IP" %}}

{{% notice warning %}}
If your **Vivado** version is **newer** then **2020.1** and older then **2023.2** on Windows you might need to check the **FAQ page** to fix the makefile for later in Vitis.
{{% /notice %}}

### SoC

Now we need to create what the course is all about a System-On-Chip (SoC), look at the course name!

For now, the **communication** IP block is not used, because it does not exist yet. So we need to recreate the SoC once it is ready!

We start by **creating a new vivado project**. I typically give it a name ending with _soc, but feel free to do something else.

This Vivado project is special, you will **not** write VHDL, but you will **create a block design**.

We can press the button **Create block design** on the left side and press ok. Here we see our block design, which is currently empty. First we add the **ZYNQ7 Proccesing System** by first clicking the **+** button on top or right mouse button **add IP**. Once we have this we also want to add **our IP**, but if you search for it **you will not find it**!

This is because we still need to **add the IP repository** to the new project so it knows where to look for our IP. You do this in the settings on the left then IP->Repository.

When added it will show you that you how many IPs are found in the IP repository.

{{% figure src="/img/ch2/ip_repository.png" title="IP repostiry" %}}

Now we **add** our **XMAS IP** to the block diagram.

{{% figure src="/img/ch2/block_diagram_unconnected.png" title="Unconnceted block diagram" %}}

If you look on top you should have 2 new buttons. One is *Run Block Automation* and the other *Run connection automation*. Both will help us connecting the IP in the right way.
You can press **run block automation** and here you can configure a few parameters of the processing system. You can just **press OK** here, the default is good. Now you will see it connected the DDR and FIXED_IO to outside ports.

Now we can also press **run connection automation**. Here we can specify which clock to use, but we have only 1 clock which comes from the *processing system*, so we can **press OK**. Now we will see it connected the AXI side of our IP through some blocks to the processing system. It generated an AXI interconnect block to interconnect the AXI bus from the processing system to our core. And it generated a *processor system reset* block which handles the reset of the AXI bus.

Note that we use the *FCLK_CLK0* from the Processing System as our clock. But at which frequency does it operate? 

By **double clicking** the **processing system** we can configure it. It has a lot of options from I/O interfaces to memory. But we are interested in the programmable logic or PL clock. On the left we click **Clock configuration** and got to **PL Fabrick Clocks**. Here we can change the clock of **FCLK_CLK0**, we use a clock of **100 MHz** for our project.

{{% notice note %}}
If your block design does not look organized you can press the **rotating arrow** button called *Regenerate Layout* to let Vivado reorder the block locations.
{{% /notice %}}

You might also have noticed that our **IP output signals** are not connected. We can fix this by **selecting them all** by **holding CTRL** and do **right mouse button make external**. Now it created output pins for those signals. But we still need to add these signals to our **.xdc file**. The DDR and FIXED_IO for the processing system are automatically included.

{{% notice note %}}
We do **not** need to **define a clock** in the **.xdc** file because we use the clock of the processing system!
{{% /notice %}}

Also note that there is a **Address editor** tab. Here is defined in which area of the memory our IP sits. Remember we were creating a MMIO (Memory-Mapped IO). This is were we can configure which memory location will be used for which IP. What we will do in **software** is **write** to **this address**, on my example 43C0_0000, and it will appear in **slv_reg0** of our IP. This we connected to **command** input of **our design**!


{{% figure src="/img/ch2/address_editor.png" title="Address editor" %}}

Once the <b>block design</b> is finished, a <b>HDL wrapper</b> needs to be generated. This can be done by right clicking on the block design and letting Vivado manage the wrapper. Finally, the toolchain can be ran: synthesis, implementation, bitstream generation.

{{% notice warning %}}
Verify that, with the bitstream generated, there are no timing violations !!
{{% /notice %}}

If everything went well you should have a final design similar to this.

{{% figure src="/img/ch2/full_block_diagram.png" title="Block diagram finished" %}}
<!-- 
{{< youtube id="s3X2rotphUA?rel=0" >}}
-->
{{% notice note %}}
Depending on your version of the tools, the layout might look different. Also different labels might be used on the buttons, but the general flow should be similar (if not identical).
{{% /notice %}}


If all is well, the hardware design can be <b>exported</b>. Make sure you tick the **export bitstream** check-box so the freshly generated bitstream is present in the Vitis environment.

{{% figure src="/img/ch2/export_hardware.png" %}}
