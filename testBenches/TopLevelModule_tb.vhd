--library declaration
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--entity
entity TopLevelModule_tb is
		generic(
			RS232_DATA_BITS		:integer:=8

		);

end entity;

--architecture
architecture rtl of TopLevelModule_tb is

	component TopLevelModule is
		generic(
			RS232_DATA_BITS		:integer:=8;
			BAUD_RATE		  	:integer:=115200;
			SYS_CLK_FREQ 	 	:integer:=27000000
		);
		port(
			clk				:in std_logic;
			Rst				:in std_logic;
			
			--RS232 ports
			rs232_rx_pin		:in std_logic;
			rs232_tx_pin		:out std_logic
			
		);

	end component;
signal			clk				: std_logic:='0';
signal			Rst				:std_logic;
			
			--RS232 ports
signal			rs232_rx_pin		:std_logic;
signal			rs232_tx_pin		: std_logic;
signal 			TransmittedData		:std_logic_vector(RS232_DATA_BITS-1 downto 0);
signal 			FinalTransmittedData		:std_logic_vector(RS232_DATA_BITS-1 downto 0);

begin


	clk <= not clk after 18.5ns;
	
	UUT_TopLevelModule:TopLevelModule 
		generic map(
			RS232_DATA_BITS		=>RS232_DATA_BITS,
			BAUD_RATE		  	=>115200,
			SYS_CLK_FREQ 	 	=>27000000
		)
		port map(
			clk					=>clk,
			Rst					=>Rst,
			
			--RS232 ports
			rs232_rx_pin		=>rs232_rx_pin,
			rs232_tx_pin		=>rs232_tx_pin
			
		);
		
	SerialToParallel:process
	begin
		--waiting for start bit
		wait until falling_edge(rs232_tx_pin);
		--waiting until the middle of the start bit
		wait for 4.3us;
		
		for i in 1 to RS232_DATA_BITS loop
			--wait until the middle of the data
			wait for 8.7us;
			TransmittedData(i-1)<=rs232_tx_pin;
		end loop;
		
		--last wait to make sure that the stop bit is transmitted
		wait for 8.7us;
		FinalTransmittedData<=TransmittedData;
	end process;
	
	
	testProcess:process
		variable TrasnmitDataVector :std_logic_vector(RS232_DATA_BITS-1 downto 0);
		procedure TRANSMIT_CHARACTER
		(
			constant TransmitData :in integer
			
		)is
		begin
			TrasnmitDataVector:=std_logic_vector(to_unsigned(TransmitData,RS232_DATA_BITS));
			
			rs232_rx_pin<='0';--transmitting the start bit
			wait for 8.7us;
			-- transmitting data LSB first
			for i in 1 to RS232_DATA_BITS loop 
				rs232_rx_pin<=TrasnmitDataVector(i-1);
				wait for 8.7us;
			end loop;
			rs232_rx_pin<='1';--transmitting the stop bit
			wait for 8.7us;
		
		end procedure;
	begin
	
	rst<='1';
	rs232_rx_pin<='1';
	wait for 100ns;
	rst<='0';
	wait for 100ns;
	
	for i in 0 to 255 loop
		TRANSMIT_CHARACTER(i);
		wait for 20us;
	end loop;
	
	
		wait;
	end process;

	
end rtl;