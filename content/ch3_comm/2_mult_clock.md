---
title: 'Multiple clocks'
chapter: false
weight: 32
draft: false
---

A lot of designs, today, have multiple clock signals. Even in our rather simple exercise a second **100 kHZ** pops up. When multiple clock signals are present, special attention is required !!

## Clock domain crossing

All the components that are synchronised to one clock form a group that is called a **clock domain**. In our example we have two clock domains (the 100 MHz and the 100 kHz). 

When signals switch from one clock domain to the other, **bad stuff** can happen. There is an [**EE Times**](https://www.eetimes.com/understanding-clock-domain-crossing-issues/) article that explains the possible issues (and fixes) very well. The three main issues with clock domain crossing are: 

0. **Metastability**: a signal which *between* a logical high and logical low level
0. **Data loss**: a bit of information (literally: a bit) is lost
0. **Data incoherency**: a bit in a word is delayed, for example

The aforementioned article presents a nice flow chart that helps you to *clean your design*

{{% figure src="https://www.eetimes.com/wp-content/uploads/media-1071300-apafig16.gif" title="Flow chart to clean your design for clock domain crossing signals" %}}
{{% source src="eetimes.com" %}}


{{% notice tip %}}
During Jo Vliegen his final two **job interviews**, he was asked to explain the **threats** in and **solutions** for clock domain crossing.
{{% /notice %}}

## Suggested approach

Not to complicate the design too much, it is best to keep as much of the design as possible in a single clock domain. One fact which we can rely on is that the frequencies of both clocks is fixed, their phase shift, however is unknown. 

<div class="multicolumn">
  <div class="column">
    Let's follow the flow-chart above:
    <ul>
      <li>Synchronous clocks ? <b>yes</b> ( 10 ns * 1000 = 10 µs ) </li>
      <li>Clock edges can be close ? <b>yes</b></li>
      <li>Synchroniser present ?<b>no</b></li>
      <li><b>action:</b> add synchroniser</li>
      <li>Separately synchronised converging signals ? <b>no</b> (our 2 wires are synchronised on the same clock) </li>
      <li>Clock edges close for continuous cycles ? <b>no</b> (because the big difference in frequencies)</li>
      <li>Fast to slow crossing ? <b>no</b></li>
    </ul>

A quick scan through the flowchart learns that a synchroniser is required. This is the synchroniser we will use in this lecture. We do it this way because we can't use the scl as a clock because we need to be able to detect the start and stop bits.
  </div>
  <div class="column">
{{% figure src="/img/ch3/synchroniser.png" title="The synchroniser we will use" %}}
  </div>
</div>