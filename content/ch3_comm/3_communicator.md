---
title: 'Communicator'
chapter: false
weight: 33
draft: false
---

With the protocol fixed and the attention to CDX (clock domain crossing), design and implementation can start.

<div class="multicolumn">
  <div class="column">
<h2>I2C slave</h2>
The design you're making needs to be able to <b>receive commands</b> over I2C. For this purpose it has 2 external inputs: <b>I2C_S_scl</b> and <b>I2C_S_sda</b>. This component watches these two signals <i>all the time</i>. When a 32-bit command, <b>data</b> is received it flags this with a <b>data valid</b> signal.
  </div>
  <div class="column">
<h2>I2C master</h2>
The design you're making needs to be able to <b>send commands</b> over I2C. For this purpose it has 2 external outputs: <b>I2C_M_scl</b> and <b>I2C_M_sda</b>. Upon receiving a 32-bit command <b>data</b> and a <b>data valid</b> it sends this command using 2 external outputs: <b>I2C_M_scl</b> and <b>I2C_M_sda</b>.
  </div>
</div>


## Communicator

The final component **communicator** instantiates both the I2C master and I2C slave.

{{% figure src="/img/ch3/communicator.jpg" title="The communicator, ready for SOC-ing" %}}


### Testing (, testing, and some more testing)

```VHDL
library IEEE;
  use IEEE.std_logic_1164.ALL;

entity communicator_tb is
  generic(
    G_DATASIZE : integer := 32
  );
end communicator_tb;

architecture Behavioural of communicator_tb is

  component communicator is
    port (
      reset : in STD_LOGIC;
      clock : in STD_LOGIC;
      data_in : in STD_LOGIC_VECTOR(G_DATASIZE-1 downto 0);
      data_in_valid : in STD_LOGIC;
      data_out : out STD_LOGIC_VECTOR(G_DATASIZE-1 downto 0);
      data_out_valid : out STD_LOGIC;
      I2C_S_scl : in STD_LOGIC;
      I2C_S_sda : in STD_LOGIC;
      I2C_M_scl : out STD_LOGIC;
      I2C_M_sda : out STD_LOGIC    
    );
  end component;

  signal reset, clock : STD_LOGIC;
  signal I2C_S_scl, I2C_S_sda : STD_LOGIC;
  signal I2C_M_scl, I2C_M_sda : STD_LOGIC;
  signal data_in_valid, data_out_valid : STD_LOGIC;
  signal data_in, data_out : STD_LOGIC_VECTOR(G_DATASIZE-1 downto 0);
  signal TX_data, RX_data : STD_LOGIC_VECTOR(G_DATASIZE-1 downto 0);
  signal TX_valid, RX_valid : STD_LOGIC;

  signal I2C_S_scl_d : STD_LOGIC;
  signal bitcounter : integer;

  constant clock_period : time := 10 ns;
  constant I2C_clock_period : time := 10 us;

  procedure pro_I2C_send (
    signal data : in std_logic_vector(G_DATASIZE-1 downto 0);
    signal scl : out std_logic;
    signal sda : out std_logic
    ) is
  begin
    -- IDLE
    scl <= '1'; 
    sda <= '1';
    wait for I2C_clock_period;

    -- START CONDITION
    sda <= '0';
    wait for I2C_clock_period/2;

    -- BIT MSB..LSB
    for I in G_DATASIZE-1 downto 0 loop
      scl <= '0';
      wait for I2C_clock_period/4;
      sda <= data(I);
      wait for I2C_clock_period/4;
      scl <= '1';
      wait for I2C_clock_period/2;
    end loop;

    scl <= '0';
    sda <= '0';
    wait for I2C_clock_period/2;
    scl <= '1';
    wait for I2C_clock_period/2;
    sda <= '1';

  end pro_I2C_send;

begin

  -------------------------------------------------------------------------------
  -- STIMULI
  -------------------------------------------------------------------------------
  PSTIM: process
  begin
    reset <= '1';
    data_in_valid <= '0';
    data_in <= (others => '0');
    TX_data <= x"00000000";
    TX_valid <= '0';
    I2C_M_scl <= '1';
    I2C_M_sda <= '1';
    wait for clock_period*10;

    reset <= '0';
    wait for clock_period*10;

    --Test scenario 1: Data coming from external source
    --test 1 (random number)
    TX_data <= x"EB012345"; TX_valid <= '1';
    wait for clock_period;
    TX_valid <= '0';
    pro_I2C_send(TX_data, I2C_M_scl, I2C_M_sda);
    wait until data_out_valid = '1';
    assert(data_out = TX_data) report "incorrect receiving" severity error;
    TX_data <= x"00000000";

    -- test 2 (receiving a second 'command')
    TX_data <= x"FEDCBA98"; TX_valid <= '1';
    wait for clock_period;
    TX_valid <= '0';
    pro_I2C_send(TX_data, I2C_M_scl, I2C_M_sda);
    wait until data_out_valid = '1';
    assert(data_out = TX_data) report "incorrect receiving" severity error;
    TX_data <= x"00000000";

    -- test 3 (cornercase: all '0')
    TX_data <= x"00000000"; TX_valid <= '1';
    wait for clock_period;
    TX_valid <= '0';
    pro_I2C_send(TX_data, I2C_M_scl, I2C_M_sda);
    wait until data_out_valid = '1';
    assert(data_out = TX_data) report "incorrect receiving" severity error;
    TX_data <= x"00000000";

    -- test 4 (cornercase: all '1')
    TX_data <= x"FFFFFFFF"; TX_valid <= '1';
    wait for clock_period;
    TX_valid <= '0';
    pro_I2C_send(TX_data, I2C_M_scl, I2C_M_sda);
    wait until data_out_valid = '1';
    assert(data_out = TX_data) report "incorrect receiving" severity error;
    TX_data <= x"00000000";

    report "Test scenario 1: OK" severity note;

    -- Test scenario 2: Data going to external source
    -- test 1 (random number)
    data_in <= x"EB012345";
    data_in_valid <= '1';
    wait for clock_period*2;
    data_in_valid <= '0';
    wait until RX_valid = '1';
    assert(RX_data = data_in) report "incorrect sending" severity error;
    data_in <= x"00000000";
   
    -- test 2 (sending a second 'command')
    data_in <= x"FEDCBA98";
    data_in_valid <= '1';
    wait for clock_period*2;
    data_in_valid <= '0';
    wait until RX_valid = '1';
    assert(RX_data = data_in) report "incorrect sending" severity error;
    data_in <= x"00000000";

    -- test 3 (cornercase: all '0')
    data_in <= x"00000000";
    data_in_valid <= '1';
    wait for clock_period*2;
    data_in_valid <= '0';
    wait until RX_valid = '1';
    assert(RX_data = data_in) report "incorrect sending" severity error;
    data_in <= x"00000000";
   
    -- test 4 (cornercase: all '1')
    data_in <= x"FFFFFFFF";
    data_in_valid <= '1';
    wait for clock_period*2;
    data_in_valid <= '0';
    wait until RX_valid = '1';
    assert(RX_data = data_in) report "incorrect sending" severity error;
    data_in <= x"00000000";
    report "Test scenario 2: OK" severity note;

    wait;
  end process;

  -------------------------------------------------------------------------------
  -- DEVICE UNDER TEST
  -------------------------------------------------------------------------------
  DUT: component communicator
   port map(
    reset => reset,
    clock => clock,
    data_in => data_in,
    data_in_valid => data_in_valid,
    data_out => data_out,
    data_out_valid => data_out_valid,
    I2C_S_scl => I2C_M_scl,
    I2C_S_sda => I2C_M_sda,
    I2C_M_scl => I2C_S_scl,
    I2C_M_sda => I2C_S_sda
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

  -------------------------------------------------------------------------------
  -- I2C MONITOR
  -------------------------------------------------------------------------------
  process
    variable I : integer;
  begin
    I := 0;
    while I < 1000 loop 
      bitcounter <= 0;
      RX_valid <= '0';
      RX_data <= x"00000000";

      -- wait for start condition
      while not(I2C_S_scl = '1' and I2C_S_sda = '0') loop
        wait for clock_period;
      end loop;

      -- receive G_DATASIZE bits
      while bitcounter < G_DATASIZE loop
        if I2C_S_scl = '1' and I2C_S_scl_d = '0' then 
          RX_data <= RX_data(RX_data'high-1 downto 0) & I2C_S_sda;
          bitcounter <= bitcounter + 1;
        end if;

        wait for clock_period;
      end loop;

      -- wait for stop condition
      wait until I2C_S_scl = '1';
      wait until I2C_S_sda = '1';

      -- wait for I2C clock period to finish
      wait for I2C_clock_period/2;

      -- signal complete reception
      RX_valid <= '1';
      wait for clock_period*1;
      RX_data <= x"00000000";
      RX_valid <= '0';
      
    end loop;

  end process;

  process(clock)
  begin
    if rising_edge(clock) then 
      I2C_S_scl_d <= I2C_S_scl;
    end if;
  end process;


end Behavioural;
```
