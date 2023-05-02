---
title: 'Communication'
chapter: false
weight: 31
draft: false
---

Up until this chapter you've created and implemented **a design** that drives lights. There are fancy colours and nice effects. Additionally the design is wrapped in an **IP core**. This IP core is used in a **SOC** to make the design programmable.

Communication has been done through a commincator IP core. This component allows bidirectional communication to send instructions to processor. The processor forwards the instructions to the IP core.

In the next step you're going to add communication. Next to receiving commands through the IP core, commands can also enter externally.

## Inter-Integrated Chip

Not to complicate things too much, the **I²C** protocol is chosen. Wikipedia starts is article with: 

> **I2C** (Inter-Integrated Circuit), pronounced I-squared-C, is a synchronous, multi-master, multi-slave, packet switched, single-ended, serial communication bus invented in 1982 by Philips Semiconductor (now NXP Semiconductors). 

Although this protocol, in its entirety, provides quite some features; the main reason for choosing this protocol is the fact that only **two** wires are required. To simplify the task at hand even further we are not going to use the full protocol. The following simplifications are made:

* only single-master, single-slave
* only the original speed is used: 100 kbit/s
* only one direction of communication: from master to slave
* no direct use of addressing (although it will be present indirectly)

The protocol is shown in the image below.

{{% figure src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/I2C_data_transfer.svg/600px-I2C_data_transfer.svg.png" title="Example of data transfer in I2C" %}}
{{% source src="wikipedia.org" url="https://en.wikipedia.org/wiki/I%C2%B2C#Timing_diagram" %}}

There are only two wires: a **data** wire and a **clock** wire, **sda** and **scl** respectively. When there is no activity, both signals are logical '1'. There is a start condition prior to data communication which is a falling edge of sda while scl is high. There is a stop condition after communication which is a rising edge of sda while scl is high.

During the data communication the **scl** signal clocks at a frequency of 100 kHz. On the high level of the clock, **sda** is sampled while on the low level of the clock, **sda** is updated.

{{% notice note %}}
The complete I2C protocol is much more substantial than the way we are using it here.
{{% /notice %}}
