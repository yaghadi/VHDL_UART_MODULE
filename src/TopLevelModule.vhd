--library declaration
library ieee;
use ieee.std_logic_1164.all;

--entity
entity TopLevelModule is
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
		rs232_tx_pin		:out std_logic;

        leds		        :out std_logic_vector(0 to 5)
		
	);

end entity;

--architecture
architecture rtl of TopLevelModule is
	
	component UART_tx is
	generic(
		RS232_DATA_BITS :integer;
		SYS_CLK_FREQ :integer;
		BAUD_RATE : integer
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		TxStart :in std_logic;
		TxData 	:in std_logic_vector(RS232_DATA_BITS-1 downto 0);
		TxReady :out std_logic;
		UART_tx_pin	:out std_logic
	);
	end component;
	
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
type state_type is (IDLE,START_TRANSMITTER);
signal SMVariable :state_type;
signal TxStart 			: std_logic;
signal TxReady 			: std_logic;
signal RxIRQ 			: std_logic;
signal RxData 			: std_logic_vector(RS232_DATA_BITS-1 downto 0);
begin
    leds <= not(RxData(5 downto 0)) ;
	UUT_UART_tx:UART_tx 
	generic map(
		RS232_DATA_BITS		=>RS232_DATA_BITS,
		BAUD_RATE		  	=>BAUD_RATE,
		SYS_CLK_FREQ 	 	=>SYS_CLK_FREQ
	)
	port map(
		clk 			=>clk,
		rst 			=>rst,
		
		TxStart 		=>TxStart,
		TxData 			=>RxData,
		TxReady 		=>TxReady,
		UART_tx_pin		=>(rs232_tx_pin)
	);
	
	UUT_UART_rx:UART_rx
	generic map(
		RS232_DATA_BITS		=>RS232_DATA_BITS,
		BAUD_RATE		  	=>BAUD_RATE,
		SYS_CLK_FREQ 	 	=>SYS_CLK_FREQ
	)
	port map(
		clk				 =>clk,
		Rst				 =>Rst,
		RS232_Rx		 =>(rs232_rx_pin ),--Serial Asynchronous signal
		RxIRQClear		 =>TxStart,
		RxIRQ			 =>RxIRQ,
		RxData			 =>RxData
	);
	
	SM_proc:process(clk,rst)
	begin
		if rst='1' then 
			TxStart<='0';
			SMVariable <=IDLE;
		elsif rising_edge(clk) then
		
			case SMVariable is
				
				When IDLE => 
					if RxIRQ='1' and  TxReady= '1'then
						SMVariable<=START_TRANSMITTER;
						TxStart<='1';
                        
					end if;	
					
				When START_TRANSMITTER =>
					TxStart<='0';
					SMVariable <=IDLE;
					
				when others=>
					SMVariable <=IDLE;
			end case;
		
		end if;
	end process;
	
end rtl;