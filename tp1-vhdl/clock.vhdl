library ieee; 
use ieee.std_logic_1164.all;
library work;


entity clock_generator is
   port ( clk : out  std_logic );
end entity;


architecture behaviorial of clock_generator is
   constant clk_period : time := 1 ns;

   begin
   clock_process :process
   begin
     clk <= '0';
     wait for clk_period/2;  --for 0.5 ns signal is '0'.
     clk <= '1';
     wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;

end;



library ieee; 
use ieee.std_logic_1164.all;
library work;

entity registre is
  port(clk, enable, d, reset : in std_logic;
       q : out std_logic );
end entity;


architecture behaviorial of registre is
begin
  reg_process : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        q <= '0';
      else
        q <= d;

library ieee;
use ieee.std_logic_1164.all;
library work;

entity Reg_N_Reset is
  generic (n: integer);
  port( clk,reset,enable : in std_logic;
        d : in std_logic_vector(n-1 downto 0);
        q : out std_logic_vector(n-1 downto 0));
end entity;

architecture behaviorial of Reg_N_Reset is
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if enable = '1' then
        if reset = '1' then
          q <= (n-1 downto 0 => '0');
        else
          q <= d;
        end if;
      end if;
    end if;
  end process;
end;

library ieee; 
use ieee.std_logic_1164.all;
library work;

entity Reg_N_Reset is
  generic (n : integer);
  port(clk,enable,reset : in std_logic;
       d : in std_logic_vector(n-1 downto 0);
       q : out std_logic_vector(n-1 downto 0)
       );
end entity;

architecture rtl of Reg_N_Reset is
  component registre is
      port(clk, enable, d, reset : in std_logic;
       q : out std_logic );
  end component;
  
        
-- library ieee;
-- use ieee.std_logic_1164.all;
-- library work;

-- entity testbench_Reg_N_Reset is
-- end entity;

-- architecture behaviorial of testbench_Reg_N_Reset is
--   component Reg_N_Reset is
--     port(d,clkin,reset,enable : in std_logic;
--          q : out std_logic);
--   end component;
--   component clock_generator is
--        port ( clkout : out  std_logic );
--   end component;

--   signal cl, en, re, de: std_logic;

-- begin
--   uut: Reg_N_Reset
--   port map(clkin => cl, clkout => cl, enable => en,
--              reset => re, d => de);
--   test_process:process
--   begin
--     wait for 0.5 ns;
--     de <= '1';
--     wait for 1 ns;
--     de <= '0';
--  end process;
-- end;
