---
title: 'Pre-scaling'
chapter: false
weight: 12
---

## Pre-scaler

One signal for which all hardware designers have to bow is **the almighty CLOCK**. In the previous exercise, you've already connect up with this signal. The clock on the {{% pynq %}} runs at 125MHz and therefore has a clock period of 8 ns.

As the final aim of this lab is to flash lights like a Christmas tree, having fancy light effects change every 8 ns would be a little quick to the eyes.

### Introducing: the tick
The easiest way to do something in the "human-perceptible-order-of-magnitude" is to use a **pre-scaler**: simply have a counter count in loops. Every time the counter hits a certain threshold, a small **tick** is given.

Having a counter go to 125'000'000 would result in 1 tick every second. So, to have 2 ticks per second, the counter needs to count to 62'500'000.

The available libraries in the design tools allow for easy counting with integers. Counting with the STD_LOGIC-type is a bit more cumbersome. 

```VHDL
  ...
  signal tick : STD_LOGIC;
  constant C_PRESCALER_MAX : integer := 125000000/2;
  signal prescaler: integer;

begin

  P_PRESC: process(clock_i)
  begin
    if rising_edge(clock_i) then 
      if reset_i = '1' then 
        prescaler <= 0;
        tick <= '0';
      else
        if prescaler = C_PRESCALER_MAX then 
          tick <= '1';
          prescaler <= 0;
        else
          tick <= '0';
          prescaler <= prescaler + 1;
        end if;
      end if;
    end if;
  end process P_PRESC;
  ...
```

### Simulation
As a good hardware designer you also **test** your design using testbenches. When you do things at the speed of around 1 Hz, simulation would take very long. For simulation it would be more convenient that the tick is generated every 250, or so, clock cycles.

It goes without saying that you can just overwrite the value of the constant **C_PRESCALER_MAX**, from the previous example, for simulation. Before generating a bitstream this could be CTRL+Z-ed. Alas, if I take myself as an example, one forgets to do this. Also, when you want to simulate again, you have to go change the constant *again*. 

A bit of a dirty hack can be a way around this.

```VHDL
  ...
  signal tick : STD_LOGIC;
  constant C_PRESCALER_MAX : integer := 125000000/(2
-- synthesis translate_off
      * 312500
-- synthesis translate_on
  );
  signal prescaler: integer;
  ...
```

The use of **pragmas** can be compared to C's **#ifdef**. The pragma used above, disables the synthesis tool between the *translate_off* and *translate_on* statements.

For more (on) pragmas, see <a href="https://insights.sigasi.com/tech/list-known-vhdl-metacomment-pragmas/" target="_blank">here</a>, or ask {{% google %}}.


<div class="multicolumn">
  <div class="column">
    <h4>Exercise 4</h4>
    <p>For this exercise use a pre-scaler to have all four LEDs flash at 1 Hz. To be more specific: the LEDs are <b>on</b> for half a second and the <b>off</b> for half a second.
    {{< youtube id="EwW-aEnM_3A?rel=0" >}}
  </div>
  <div class="column">
    <h4>Exercise 5</h4>
    <p>For this exercise, each LED flashes at <b>double</b> the frequency of its left neighbour. The left-most LED continues flashing at 1 Hz (as in the previous exercise).
    {{< youtube id="KDF-p9MeLc8?rel=0" >}}
  </div>
</div>