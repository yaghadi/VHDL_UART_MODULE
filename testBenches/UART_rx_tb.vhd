--library declaration
library ieee;
use ieee.std_logic_1164.all;

--entity
entity UART_rx_tb is
	generic (
			RS232_DATA_BITS		:integer:=8;
			BAUD_RATE		  	:integer:=115200;
			SYS_CLK_FREQ 	 	:integer:=27000000
	);
end entity;

--architecture
architecture rtl of UART_rx_tb is


	component UART_rx is
		generic(
			RS232_DATA_BITS		:integer;
			BAUD_RATE		  	:integer;
			SYS_CLK_FREQ 	 	:integer
		);
		port(
			clk				:in std_logic;
			Rst				:in std_logic;
			RS232_Rx		:in std_logic;--Serial Asynchronous signal
			RxIRQClear		:in std_logic;
			RxIRQ			:out std_logic;
			RxData			:out std_logic_vector(RS232_DATA_BITS-1 downto 0)
		);

	end component;
signal			clk				: std_logic:='0';
signal			Rst				: std_logic;
signal			RS232_Rx		: std_logic;--Serial Asynchronous signal
signal			RxIRQClear		: std_logic;
signal			RxIRQ			: std_logic;
signal			RxData			: std_logic_vector(RS232_DATA_BITS-1 downto 0);
signal 			PCData			: std_logic_vector(RS232_DATA_BITS-1 downto 0):=x"AA";

begin
	clk <= not clk after 18.5ns;
	
	UUT_UART_RX_INST:UART_rx
	generic map(
			RS232_DATA_BITS		=>RS232_DATA_BITS,
			BAUD_RATE		  	=>BAUD_RATE,
			SYS_CLK_FREQ 	 	=>SYS_CLK_FREQ
	)
	port map(
		clk				=>clk,
		Rst				=>Rst,
		RS232_Rx		=>RS232_Rx,--Serial Asynchronous signal
		RxIRQClear		=>RxIRQClear,
		RxIRQ			=>RxIRQ,
		RxData			=>RxData
	);
	
	testBench:process
	begin
	
	rst<='1';
	RS232_Rx<='1';
	RxIRQClear<='0';
	wait for 100ns;
	rst<='0';
	wait for 100ns;
	
	
	RS232_Rx<='0';--transmitting the start bit
	wait for 8.7us;
	for i in 0 to 7 loop 
		RS232_Rx<=PCData(i);-- transmitting data LSB first
		wait for 8.7us;
	end loop;
	RS232_Rx<='1';--transmitting the stop bit
	wait for 8.7us;
	
	wait for 50ns;
	wait until rising_edge(clk);
	RxIRQClear<='1';
	wait until rising_edge(clk);
	RxIRQClear<='0';
	
	
		wait;
	end process;
		
		
		
end rtl;