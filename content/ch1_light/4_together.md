---
title: Bringing it all together
chapter: false
draft: false
weight: 14
---

Up until this point you have made different hardware designs to achieve a number of features. These features will be used in the board as it functions as **Christmas light**.

Before going to a processor or communication, things needs to be fixed. The most important thing, from a hardware point of view, is the interface. The following features will need to be present:

<div class="multicolumn">
  <div class="column">
    <h4>Targets</h4>
    <ul>
      <li>LED 0</li>
      <li>LED 1</li>
      <li>LED 2</li>
      <li>LED 3</li>
      <li>RGB LED 0</li>
      <li>RGB LED 1</li>
    </ul>
  </div>
  <div class="column">
    <h4>Functions</h4>
    <ul>
      <li>fixed value on LED (0/1)</li>
      <li>blinking LED on certain frequencies</li>
      <li>the color on the RGB LEDs</li>
      <li>the brightness on the RGB LEDs</li>
    </ul>
  </div>
</div>

The configuration which will be applied to your {{% pynq %}}, eventually, will come through communication. For now, you will prepare it for communication with a processor. As we all have to agree on the **interface** and the **commands** the following is proposed:

{{% figure src="/img/ch1/commands.svg" %}}

### LEDs
The 8 rightmost bits (bits 7 downto 0) have an effect on the LEDs. The most-significant nibble (7 downto 4) selects the affected LED(s), while the least-significant nibble selectes the affected pattern. The LED selection is **one-hot coded**, the pattern is **binary coded**.

| bit  | description  | argument  |
|---|---|---|
| 3-0 | blank the selected LED(s) | "0000" |
|  | drive the selected LED(s) | "0001" |
|  | blink the selected LED(s) | Frequency = 2<sup>(nibble % 4)</sup> Hz |
| 4 | LED 0 | *see 3-0* |
| 5 | LED 1 | *see 3-0* |
| 6 | LED 2 | *see 3-0* |
| 7 | LED 3 | *see 3-0* |

### RGB LEDs
The next-to-last 10 bits (bits 17 downto 8) have an effect on the RGB LEDs. The 6 most significant bits select the affected RGB LED(s), while the least-significant nibble selectes the affected pattern. The selection is **one-hot coded**, the pattern is **binary coded**.

| bit  | description  | argument  |
|---|---|---|
| 11-8 | duty cycle | "0000" = 0%, "1111" = 100% |
| 12 | red on RGB LED 0 | *see 11-8* |
| 13 | green on RGB LED 0 | *see 11-8* |
| 14 | blue on RGB LED 0 | *see 11-8* |
| 15 | red on RGB LED 1 | *see 11-8* |
| 16 | green on RGB LED 1 | *see 11-8* |
| 17 | blue on RGB LED 1 | *see 11-8* |


### Operation
The commands are explained above. A few example are given here. 

* When the {{% pynq %}} receives the command **0x000000F1**, this selects ALL the *LEDs* (because of the **F**) and their operation is: LED on (because of the **1**). 
* When the {{% pynq %}} receives the command **0x00008F00**, this selects the Red led from RGB LED 1 and it turns it on.
* When the {{% pynq %}} receives the command **0x0000471C**, this selects the Blue led from RGB LED 0 and it turns it on with a (roughly)
 50% duty cycle. **Additionally** is has the left most LED oscillate at 1 Hz.

As you can see from the examples above, the commands can have one single effect, or can have multiple effects. This allows us configure the lights more finely grained. If you would want to recreate exercise 4, you would have to send four commands: **0x1C**, **0x2D**, **0x4E**, **0x8F**. 

{{% notice note %}}
It is useful to **keep a copy** of the configuration for each *target*. Otherwise every command would overwrite the previous command. Off course it is not required to keep the complete configuration for each target. Only the relevant information needs to be **memorised**.
{{% /notice %}}

To indicate that a command is *ready-for-interpretation*, a single input is used: **command_valid**. As long as this input is high, the *command* should stay constant. There are no other limitations. The image below gives an example how the commands can be received to recreate exercise 4.

{{% figure src="/img/ch1/wavedrom.png" %}}

<div class="source">
Image created with <a href="https://wavedrom.com/" target="_blank">WaveDrom</a>
</div>

<!-- {signal: [
  { name: "clock", wave: 'p................' },
  { name: "command", wave: 'x3..|.6...4.5..x.', data: ['0x1C', '0x2D', '0x3E', '0x4F']},
  { name: 'command_valid', wave: '0.10...10..1.0...'}
]}
-->

### Final layout

The entity/module on the hierarchical top-level should look as shown below. Keep the port names as they are shown in the VHDL/Verilog code below. 
{{% figure src="/img/ch1/ipcore_lite.jpg" %}}


<div class="multicolumn">
  <div class="column">
    <h4>VHDL</h4>
<div class="highlight"><pre style="color:#f8f8f2;background-color:#272822;-moz-tab-size:4;-o-tab-size:4;tab-size:4"><code class="language-VHDL" data-lang="VHDL"><span style="color:#66d9ef">entity</span> <span style="color:#a6e22e">xmas_light</span> <span style="color:#66d9ef">is</span>
  <span style="color:#66d9ef">port</span> (
    reset <span style="color:#f92672">:</span> <span style="color:#66d9ef">in</span> <span style="color:#66d9ef">STD_LOGIC</span>;
    clock <span style="color:#f92672">:</span> <span style="color:#66d9ef">in</span> <span style="color:#66d9ef">STD_LOGIC</span>;
    command <span style="color:#f92672">:</span> <span style="color:#66d9ef">in</span> <span style="color:#66d9ef">STD_LOGIC_VECTOR</span>(<span style="color:#ae81ff">31</span> <span style="color:#66d9ef">downto</span> <span style="color:#ae81ff">0</span>);
    command_valid <span style="color:#f92672">:</span> <span style="color:#66d9ef">in</span> <span style="color:#66d9ef">STD_LOGIC</span>;
    RGB0 <span style="color:#f92672">:</span> <span style="color:#66d9ef">out</span> <span style="color:#66d9ef">STD_LOGIC_VECTOR</span>(<span style="color:#ae81ff">2</span> <span style="color:#66d9ef">downto</span> <span style="color:#ae81ff">0</span>);
    RGB1 <span style="color:#f92672">:</span> <span style="color:#66d9ef">out</span> <span style="color:#66d9ef">STD_LOGIC_VECTOR</span>(<span style="color:#ae81ff">2</span> <span style="color:#66d9ef">downto</span> <span style="color:#ae81ff">0</span>);
    LEDs <span style="color:#f92672">:</span> <span style="color:#66d9ef">out</span> <span style="color:#66d9ef">STD_LOGIC_VECTOR</span>(<span style="color:#ae81ff">3</span> <span style="color:#66d9ef">downto</span> <span style="color:#ae81ff">0</span>)
  );
<span style="color:#66d9ef">end</span> <span style="color:#a6e22e">xmas_light</span>;</code><span class="copy-to-clipboard" title="Copy to clipboard"></span></pre></div>
  </div>

  <div class="column">
    <h4>Verilog</h4>
<div class="highlight"><pre style="color:#f8f8f2;background-color:#272822;-moz-tab-size:4;-o-tab-size:4;tab-size:4"><code class="language-verilog" data-lang="verilog"><span style="color:#66d9ef">module</span> xmas_light (
  <span style="color:#66d9ef">input</span>         reset,
  <span style="color:#66d9ef">input</span>         clock,
  <span style="color:#66d9ef">input</span>  [<span style="color:#ae81ff">31</span><span style="color:#f92672">:</span><span style="color:#ae81ff">0</span>] command,
  <span style="color:#66d9ef">input</span>         command_valid,
  <span style="color:#66d9ef">output</span> [<span style="color:#ae81ff">2</span><span style="color:#f92672">:</span><span style="color:#ae81ff">0</span>]  rgb0,
  <span style="color:#66d9ef">output</span> [<span style="color:#ae81ff">2</span><span style="color:#f92672">:</span><span style="color:#ae81ff">0</span>]  rgb1,
  <span style="color:#66d9ef">output</span> [<span style="color:#ae81ff">3</span><span style="color:#f92672">:</span><span style="color:#ae81ff">0</span>]  leds
);
</code><span class="copy-to-clipboard" title="Copy to clipboard"></span></pre></div>
  </div>
</div>

<div class="multicolumn">
  <div class="column">
  </div>
  <div class="column">
  </div>
</div>


### Testing (, testing, and some more testing)

With the toplevel-design ready, it needs to be tested. Remember the rule-of-thumb which states that **for each hour of designing you should spend two hours on testing !!**

The VHDL-code below shows an example of the testbench. Verilog users can also use a **VHDL** testbench (and the other way around) !! An example waveform as shown below, should be obtained.

<div class="multicolumn">
  <div class="column">
{{% figure src="/img/ch1/together_LED.png" %}}
  </div>
  <div class="column">
{{% figure src="/img/ch1/together_RGBLED.png" %}}
  </div>
    <div class="column">
{{% figure src="/img/ch1/together_complete.png" %}}
  </div>
</div>



```VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xmas_light_tb is
end xmas_light_tb;

architecture Behavioural of xmas_light_tb is

  component xmas_light is
    port (
      reset : in STD_LOGIC;
      clock : in STD_LOGIC;
      command : in STD_LOGIC_VECTOR(31 downto 0);
      command_valid : in STD_LOGIC;
      RGB0 : out STD_LOGIC_VECTOR(2 downto 0);
      RGB1 : out STD_LOGIC_VECTOR(2 downto 0);
      LEDs : out STD_LOGIC_VECTOR(3 downto 0)
    );
  end component;

  signal reset, clock : STD_LOGIC;
  signal command : STD_LOGIC_VECTOR(31 downto 0);
  signal command_valid : STD_LOGIC;
  signal RGB0 : STD_LOGIC_VECTOR(2 downto 0);
  signal RGB1 : STD_LOGIC_VECTOR(2 downto 0);
  signal LEDs : STD_LOGIC_VECTOR(3 downto 0);

  constant clock_period : time := 10 ns;

begin

  -------------------------------------------------------------------------------
  -- STIMULI
  -------------------------------------------------------------------------------
  PSTIM: process
  begin
    reset <= '1';
    command <= x"00000000";
    command_valid <= '0';
    wait for clock_period*10;

    reset <= '0';
    wait for clock_period*1000;
    
    --*************************************************************************

    -- turn on all LEDs
    command <= x"000000_F1";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- turn off all LEDs
    command <= x"000000_F0";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate all LEDs at 1 Hz
    command <= x"000000_FC";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate all LEDs at 2 Hz
    command <= x"000000_FD";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate all LEDs at 4 Hz
    command <= x"000000_FE";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate all LEDs at 8 Hz
    command <= x"000000_FF";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- turn off all LEDs
    command <= x"000000_F0";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    --*************************************************************************

    -- turn on LED(0)
    command <= x"000000_11";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- turn off LED(0)
    command <= x"000000_10";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(0) at 1 Hz
    command <= x"000000_1C";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(0) at 2 Hz
    command <= x"000000_1D";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(0) at 4 Hz
    command <= x"000000_1E";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(0) at 8 Hz
    command <= x"000000_1F";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- turn off all LEDs
    command <= x"000000_F0";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    --*************************************************************************

    -- turn on LED(1)
    command <= x"000000_21";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- turn off LED(1)
    command <= x"000000_20";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(1) at 1 Hz
    command <= x"000000_2C";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(1) at 2 Hz
    command <= x"000000_2D";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(1) at 4 Hz
    command <= x"000000_2E";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(1) at 8 Hz
    command <= x"000000_2F";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

      -- turn off all LEDs
    command <= x"000000_F0";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;


    --*************************************************************************

    -- turn on LED(2)
    command <= x"000000_41";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- turn off LED(2)
    command <= x"000000_40";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(2) at 1 Hz
    command <= x"000000_4C";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(2) at 2 Hz
    command <= x"000000_4D";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(2) at 4 Hz
    command <= x"000000_4E";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(0) at 8 Hz
    command <= x"000000_4F";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- turn off all LEDs
    command <= x"000000_F0";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    --*************************************************************************
    
    -- turn on LED(3)
    command <= x"000000_81";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- turn off LED(3)
    command <= x"000000_80";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(3) at 1 Hz
    command <= x"000000_8C";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(3) at 2 Hz
    command <= x"000000_8D";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(3) at 4 Hz
    command <= x"000000_8E";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;

    -- oscillate LED(1) at 8 Hz
    command <= x"000000_8F";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;


    -- turn off all LEDs
    command <= x"000000_F0";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*1000;


    -- turn off all RGB LEDs
    command <= x"000_3F0_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on RED_0 - PWM1
    command <= x"000_011_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on GREEN_0 - PWM2
    command <= x"000_022_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on BLUE_0 - PWM3
    command <= x"000_043_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on RED_1 - PWM4
    command <= x"000_084_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on GREEN_1 - PWM5
    command <= x"000_105_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on BLUE_1 - PWM6
    command <= x"000_206_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on RED_0 - PWM7
    command <= x"000_017_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on GREEN_0 - PWM8
    command <= x"000_028_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on BLUE_0 - PWM9
    command <= x"000_049_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on RED_1 - PWMA
    command <= x"000_08A_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on GREEN_1 - PWMB
    command <= x"000_10B_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on BLUE_1 - PWMC
    command <= x"000_20C_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on RED_0 - PWMD
    command <= x"000_01D_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on GREEN_0 - PWME
    command <= x"000_02E_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on BLUE_0 - PWMF
    command <= x"000_04F_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on RED_1 - PWMF
    command <= x"000_08F_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on GREEN_1 - PWMF
    command <= x"000_10F_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on BLUE_1 - PWMF
    command <= x"000_20F_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on RED_0 - PWMF
    command <= x"000_01F_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    -- turn on GREEN_0 - PWME
    command <= x"000_02F_00";  command_valid <= '1';  wait for clock_period*4;
    command <= x"000_000_00";  command_valid <= '0';  wait for clock_period*4;
    wait for clock_period*10000;

    wait;
  end process;


  -------------------------------------------------------------------------------
  -- DEVICE UNDER TEST
  -------------------------------------------------------------------------------
  DUT: component xmas_light port map(
    reset => reset,
    clock => clock,
    command => command,
    command_valid => command_valid,
    RGB0 => RGB0,
    RGB1 => RGB1,
    LEDs => LEDs
  );

  
  -------------------------------------------------------------------------------
  -- CLOCK
  -------------------------------------------------------------------------------
  PCLK: process
  begin
    clock <= '1';
    wait for clock_period/2;
    clock <= '0';
    wait for clock_period/2;
  end process PCLK;

end Behavioural;

```

