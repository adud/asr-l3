library ieee;
use ieee.std_logic_1164.all;
library work;

entity compteur is
  generic (n : integer);
  port(ck, en, res : in  std_logic;
       st          : out std_logic_vector(n-1 downto 0));
end entity;

architecture rtl of compteur is
  component Reg_N_Reset is
    generic (n : integer);
    port(clk, reset, enable : in  std_logic;
         d                  : in  std_logic_vector(n-1 downto 0);
         q                  : out std_logic_vector(n-1 downto 0));
  end component;

  component adder is
    generic (n : integer);  -- generic means: architectural parameter
    port(x    : in  std_logic_vector(n-1 downto 0);
         y    : in  std_logic_vector(n-1 downto 0);
         cin  : in  std_logic;
         s    : out std_logic_vector(n-1 downto 0);
         cout : out std_logic);
  end component;

  signal c1, sor, trs : std_logic_vector (n-1 downto 0);
  signal ckc, enc, rsc : std_logic;

begin
  reg : Reg_N_Reset
    generic map(n => n)
    port map (
      d => trs,
      q => sor,
      enable => enc,
      reset => rsc,
      clk => ckc
      );
  add : adder
    generic map(n => n)
    port map(
      x => c1,
      y => sor,
      s => trs
      );
  st <= sor;
  
end architecture;

