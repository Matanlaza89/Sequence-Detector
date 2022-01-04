-----------------------------------------------------------------------------
----------------  This RTL Code written by Matan Leizerovich  ---------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-------			          Sequence Detector Project            	      -------
-----------------------------------------------------------------------------
------ 	 This project reveals the sequence of the four bits that come  ------
------       from the first four switches in the development kit       ------
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity sequenceDetector is
port (
		-- Inputs --
		CLOCK_50 : in std_logic;
		KEY 	 : in std_logic_vector (3 downto 0);
		SW		 : in std_logic_vector (3 downto 0);
		
		-- Outputs --
		HEX0   : out std_logic_vector(6 downto 0);
		HEX1   : out std_logic_vector(6 downto 0);
		HEX2   : out std_logic_vector(6 downto 0);
		HEX3   : out std_logic_vector(6 downto 0);
		LEDR   : out std_logic_vector(3 downto 0);
		LEDG   : out std_logic_vector(7 downto 0)
		);
end entity sequenceDetector;

architecture rtl of sequenceDetector is
	
	-- Aliases --
	alias RESET : std_logic is KEY(0);
	alias ZERO  : std_logic is KEY(2);
	alias ONE   : std_logic is KEY(3);
	
	-- Types --
	type t_state is (s_idle,s_first,s_second,s_third,s_fourth);
	
	-- Signals --
	signal r_state : t_state := s_idle;
	signal r_ZERO  : std_logic := '0';
	signal r_ONE   : std_logic := '0';
	signal r_LEDR  : std_logic_vector(3 downto 0) := (others => '0');
	signal r_LEDG  : std_logic_vector(7 downto 0) := (others => '0');
	
	signal r_n1    : std_logic_vector(6 downto 0) := (others => '1');
	signal r_n2    : std_logic_vector(6 downto 0) := (others => '1');
	signal r_n3    : std_logic_vector(6 downto 0) := (others => '1');
	signal r_n4    : std_logic_vector(6 downto 0) := (others => '1');
	
begin
	
	-- This process samples the push button --
	p_samples_buttons : process (CLOCK_50 , ZERO , ONE) is
	begin
		if (rising_edge(CLOCK_50)) then
			r_ZERO <= ZERO;
			r_ONE <= ONE;
		end if; -- rising_edge(clk)
		
	end process p_samples_buttons;
	

	
	-- This process update the FSM state --
	p_update_state : process (CLOCK_50 , RESET) is
	begin	
		-- Asynchronous reset -- 
		if (RESET = '0') then
			r_state <= s_idle;
			
		elsif (rising_edge(CLOCK_50)) then

			-- Default values --
			HEX0   <= "1111111";
			HEX1   <= "1111111";
			HEX2   <= "1111111";
			HEX3   <= "1111111";
			r_LEDR <= X"0";
			r_LEDG <= X"00";

			-- Updates current state depends on the input --
			case (r_state) is
			
				when s_idle =>

					if (SW(3) = '0' and ZERO = '0' and r_ZERO = '1') then
						r_state <= s_first;
						r_n1 <= "1000000"; -- 0 was pressed
						
					elsif (SW(3) = '1' and ONE = '0' and r_ONE = '1') then
						r_state <= s_first;
						r_n1    <= "1111001"; -- 1 was pressed
						
					else
						r_state <= s_idle;
						r_n1    <= r_n1;
						
					end if; -- s_idle
					
					
				when s_first =>
					-- Update outputs --
					HEX3   <= r_n1;
					r_LEDR <= X"1";
							
					if (SW(2) = '0' and ZERO = '0' and r_ZERO = '1') then
						r_state <= s_second;
						r_n2 <= "1000000"; -- 0 was pressed
						
					elsif (SW(2) = '1' and ONE = '0' and r_ONE = '1') then
						r_state <= s_second;
						r_n2 <= "1111001"; -- 1 was pressed
						
					else
						r_state <= s_first;
						r_n2	  <= r_n2;
						
					end if; -- s_first
					
				when s_second =>
					-- Update outputs --
					HEX3   <= r_n1;
					HEX2   <= r_n2;
					r_LEDR <= X"3";
					
					if (SW(1) = '0' and ZERO = '0' and r_ZERO = '1') then
						r_state   <= s_third;
						r_n3 <= "1000000"; -- 0	was pressed	
						
					elsif (SW(1) = '1' and ONE = '0' and r_ONE = '1') then
						r_state   <= s_third;
						r_n3 <= "1111001"; -- 1 was pressed
						
					else
						r_state <= s_second;
						r_n3 <= r_n3;
						
					end if; -- s_second
				
				when s_third =>
					-- Update outputs --
					HEX3 <= r_n1;
					HEX2 <= r_n2;
					HEX1 <= r_n3;
					r_LEDR <= X"7";
					
					if (SW(0) = '0' and ZERO = '0' and r_ZERO = '1') then
						r_state <= s_fourth;
						r_n4    <= "1000000"; -- 0 was pressed			
					elsif (SW(0) = '1' and ONE = '0' and r_ONE = '1') then
						r_state <= s_fourth;
						r_n4    <= "1111001"; -- 1 was pressed
					else
						r_state <= s_third;
						r_n4    <= r_n4;
					end if;
					
				when s_fourth =>
					-- Update outputs --
					HEX3 <= r_n1;
					HEX2 <= r_n2;
					HEX1 <= r_n3;
					HEX0 <= r_n4;
					r_LEDR <= X"F";
					r_LEDG <= X"FF";
							
					if (ZERO = '0' and r_ZERO = '1') then
						r_state <= s_idle;	
					elsif (ONE = '0' and r_ONE = '1') then
						r_state <= s_idle;
					else
						r_state <= s_fourth;
					end if;

				when others => 
					r_state <= s_idle;
					
			end case; -- r_state of FSM
		
		end if; -- -- RESET / rising_edge(clk)
	
	end process p_update_state;
	
	-- Display Current State --
	LEDR <= r_LEDR;
	
	-- Display if sequence detection was successful --
	LEDG <= r_LEDG;

end architecture rtl;