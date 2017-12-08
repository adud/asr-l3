library ieee; 
use ieee.std_logic_1164.all;
library work;


entity clock_generator is
   port ( ck : out  std_logic );
end entity;


architecture behaviorial of clock_generator is
   constant clk_period : time := 1 ns;

   begin
   clock_process :process
   begin
     ck <= '0';
     wait for clk_period/2;  --for 0.5 ns signal is '0'.
     ck <= '1';
     wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;

end;

library ieee;
use ieee.std_logic_1164.all;
library work;

entity Reg_N_Reset is
  generic (n: integer);
  port( ck,reset,enable : in std_logic;
        d : in std_logic_vector(n-1 downto 0);
        q : out std_logic_vector(n-1 downto 0));
end entity;

architecture behaviorial of Reg_N_Reset is
begin
  process(ck)
  begin
    if rising_edge(ck) then
      if reset = '1' then
        q <= (n-1 downto 0 => '0');
      else if enable = '1' then
          q <= d;
         end if;
      end if;
    end if;
  end process;
end;
        
