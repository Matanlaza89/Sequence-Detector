-----------------------------------------------------------------------------
----------------  This RTL Code written by Matan Leizerovich  ---------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-------			        Sequence Detector TestBench			   	      -------
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sequenceDetectorTB is
end entity sequenceDetectorTB;

architecture sim of sequenceDetectorTB is
	-- Constants --
	constant c_DELAY : time := 60 us;
	constant c_PERIOD : time := 20 ns;
	constant c_LOOP_ITERATION : natural := 15;
	
	-- Stimulus signals --
	signal i_clk   : std_logic;
	signal i_reset : std_logic;
	signal i_zero  : std_logic;
	signal i_one   : std_logic;
	signal i_sw    : std_logic_vector(3 downto 0);
	
	-- Observed signal --
	signal o_HEX0 : std_logic_vector(6 downto 0);
	signal o_HEX1 : std_logic_vector(6 downto 0);
	signal o_HEX2 : std_logic_vector(6 downto 0);
	signal o_HEX3 : std_logic_vector(6 downto 0);
	signal o_LEDR : std_logic_vector(3 downto 0);
	signal o_LEDG : std_logic_vector(7 downto 0);


begin
	
	-- Unit Under Test port map --
	UUT : entity work.sequenceDetector(rtl)
	port map (
			CLOCK_50 => i_clk ,
			KEY(0)   => i_reset ,
			KEY(1)   => '1' ,
			KEY(2)   => i_zero ,
			KEY(3)   => i_one ,
			SW       => i_sw ,
			HEX0     => o_HEX0 ,
			HEX1     => o_HEX1 ,
			HEX2     => o_HEX2 ,
			HEX3     => o_HEX3 ,
			LEDR     => o_LEDR ,
			LEDG 	 => o_LEDG );
			
			
	-- Testbench process --
	p_TB : process
		variable v_counter : integer range 0 to c_LOOP_ITERATION := 0; -- 0000 to 1111
	begin
		-- Initial state --
		i_reset <= '0';
		i_zero  <= '1';
		i_one   <= '1';
		wait for c_PERIOD; 
		
		
		-- Start FSM --
		i_reset <= '1';
		
		
		-- Run 16 options for sequencing detector testing --
		for i in 0 to c_LOOP_ITERATION loop
			
			if (i_reset = '0') then
				v_counter := 0;
				
			else
				v_counter := v_counter + 1;
				
			end if; -- i_reset
		
		
			-- 4-bit vector simulation --
			i_sw <= std_logic_vector(to_unsigned(v_counter,4));
			
			
			-- Simulation of a push of a button --
			if (i_sw(3) = '1') then
				i_one <= '0'; 
				wait for c_PERIOD;
				i_one <= '1'; 
				wait for c_PERIOD;
				
			else
				i_zero <= '0'; 
				wait for c_PERIOD;
				i_zero <= '1'; 
				wait for c_PERIOD;
				
			end if; -- i_sw(3)
			
			
			if (i_sw(2) = '1') then
				i_one <= '0'; 
				wait for c_PERIOD;
				i_one <= '1'; 
				wait for c_PERIOD;
				
			else
				i_zero <= '0'; 
				wait for c_PERIOD;
				i_zero <= '1'; 
				wait for c_PERIOD;
				
			end if; -- i_sw(2)
			
			
			if (i_sw(1) = '1') then
				i_one <= '0'; 
				wait for c_PERIOD;
				i_one <= '1'; 
				wait for c_PERIOD;
				
			else
				i_zero <= '0'; 
				wait for c_PERIOD;
				i_zero <= '1'; 
				wait for c_PERIOD;
				
			end if; -- i_sw(1)
			
			
			if (i_sw(0) = '1') then
				i_one <= '0'; 
				wait for c_PERIOD;
				i_one <= '1'; 
				wait for c_PERIOD;
				
			else
				i_zero <= '0'; 
				wait for c_PERIOD;
				i_zero <= '1'; 
				wait for c_PERIOD;
				
			end if; -- i_sw(0)
			
			-- Return to s_idle state --
			i_one <= '0'; 
			wait for c_PERIOD;
			i_one <= '1'; 
			wait for c_PERIOD;
			
		end loop;
		
	wait;
	end process p_TB;
	
	
	-- 50 MHz clock in duty cycle of 50% - 20 ns --
	p_clock : process 
	begin 
		i_clk <= '0'; wait for c_PERIOD/2; -- 10 ns
		i_clk <= '1'; wait for c_PERIOD/2; -- 10 ns
	end process p_clock;

end architecture sim;