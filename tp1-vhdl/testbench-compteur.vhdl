library ieee;
use ieee.std_logic_1164.all;
library work;

entity testbench_compteur is
end entity;

architecture bhv of testbench_compteur is
  component compteur is
    generic (n : integer);
    port(ck, en, res : in  std_logic;
         st          : out std_logic_vector(n-1 downto 0));
  end component;

  component clock_generator is
    port ( ck : out  std_logic );
  end component;

  signal sor : std_logic_vector(7 downto 0);
  signal ck,en,res : std_logic;

begin
  uut:compteur
    generic map ( n=>8)
    port map(ck=>ck, en=>en, res=>res, st=>sor);

  hor:clock_generator
    port map(ck=>ck);
  test:process
  begin
    en <= '1';
    res <= '1';
    wait for 120000 ns;
    res <= '0';
    wait for 100000 ns;
  end process;
end;
