library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CND is
    generic (
        mutant      : integer := 0
    );
    port (
        rs1         : in w32;
        alu_y       : in w32;
        IR          : in w32;
        slt         : out std_logic;
        jcond       : out std_logic
    );
end entity;

architecture RTL of CPU_CND is
signal ext , s , z : std_logic;
signal soustraction , bla1 , bla2 : unsigned (32 downto 0);
begin
	ext <= ((not IR(12)) and (not IR(6))) or ((not IR(13)) and (IR(6)));
	jcond <= ((IR(12) xor z) and (not IR(14))) or ((IR(12) xor s) and IR(14));
	slt <= s;
	bla1 <= rs1(31) & rs1 when ext='1' else '0' & rs1;
	bla2 <= alu_y(31) & alu_y when ext='1' else '0' & alu_y;
	soustraction <= bla1 - bla2 ;
	s <= '1' when soustraction(32) = '1' else '0';
	z <= '1' when soustraction = (32 downto 0 => '0') else '0';
end architecture;
