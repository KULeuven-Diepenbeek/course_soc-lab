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


The different components of the SOC have to be connected to each other. This is done through an on-chip bus. A heavily used interface is the **Advanced eXtensible Interface (AXI)**, which originates from ARM. The current version is AXI4. More information on AXI can be found online, starting from [wikipedia](https://en.wikipedia.org/wiki/Advanced_eXtensible_Interface).

### IP component

Up until now, you've been working on the (hardware) functionality of the *fancy lights*. To attach your design to an AXI bus (or any other bus), the component needs a certain interface. The details on this interface itself fall out-of-scope for this lab. The Vivado design tool has a wizard that guides you through the generation of an AXI4 component. Using this wizard, the design as shown below is generated.

{{% figure src="/img/ch2/ipcore.jpg" title="The generated IP core" %}}

The entity or module that you have been working on is the **xmas_light** block in the middle. The outer most module **xmas_light_v1_0** does not do anything other than forwarding the top level inputs and outputs to **xmas_light_v1_0_S00_AXI**. 

From the naming of this middle block you can tell: 1) it is a child of xmas_light_v1_0, 2) it provides an AXI interface, and 3) the interface is *slave 0*. If the IP component has multiple interfaces, these numbers and names change.

Your IP component will be reachable by the processor through an address. This is called **Memory-Mapped IO (MMIO)**. The interface that is generated already provides a number of **slave register** in xmas_light_v1_0_S00_AXI. When the processor read from (or writes to) a certain address, these operations actually target these registers. It is up to you (the designer) **how** you will wire up these registers to your design.

For example: the 32-bit slave register 0 will be connected to the **command** input. The LSB of slave register 1 will be connected to thte **command valid**.

{{< youtube id="B-F_jVeAcfs?rel=0" >}}

{{% notice note %}}
Don't forget to **note down** the connections to the registers; and to **wire out** external signals all the way up !!!
{{% /notice %}}

### SOC

For now, the **communication** IP block is not used, because it is not existing yet. When that IP block is also finished, the SOC needs to be recreated.

{{< youtube id="s3X2rotphUA?rel=0" >}}

{{% notice note %}}
Depending on your version of the tools, the layout might look different. Also different labels might be used on the buttons, but the general flow should be similar (if not identical).
{{% /notice %}}


### Finalising

<div class="multicolumn">
  <div class="column">
Once the <b>block design</b> is finished, a <b>HDL wrapper</b> needs to be generated. This can be done by right clicking on the block design. Finally, the toolchain can be ran: synthesis, implementation, bitstream generation.

{{% notice warning %}}
Verify that, with the bitstream generated, there are no timing violations !!
{{% /notice %}}
If all is well, the hardware design can be <b>exported</b>. Make sure you tick the "export bitstream" check-box so the freshly generated bitstream is present in the SDK environment.

  </div>
  <div class="column">
    {{% figure src="/img/ch2/export_hardware.png" %}}
  </div>
</div>
