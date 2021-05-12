library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use work.HermesPackage.all;
use work.standards.all;

entity Testbench is
    generic(X_ROUTERS: integer := 2;
    	    Y_ROUTERS: integer := 2 );
end;

architecture TB of Testbench is

	signal clock : std_logic_vector( (X_ROUTERS*Y_ROUTERS-1) downto 0) := (others=>'0');
	signal reset : std_logic;
	signal clock_rx, rx, credit_o: std_logic_vector( (X_ROUTERS*Y_ROUTERS-1) downto 0);
	signal clock_tx, tx, credit_i: std_logic_vector( (X_ROUTERS*Y_ROUTERS-1) downto 0);
	signal data_in, data_out : arrayNrot_regflit( (X_ROUTERS*Y_ROUTERS-1) downto 0 );

	constant NB_ROUTERS : integer :=  X_ROUTERS * Y_ROUTERS;

	-- delta cycles
	signal cycles : integer := 0;

    -- number of packets to be transmitted
	constant NUM_PACKETS : integer := 5;

    -- vector of integer (one entry per packet)
	type ivector is array(0 to NUM_PACKETS-1) of INTEGER
		range 0 to 255;

	-- packet transmission state machine states 
	type pckstate_t is (WAITING, HEADER, SIZE, PAYLOAD, DONE);
	type pckstate is array(0 to NUM_PACKETS-1) of pckstate_t;

	signal pkt_state : pckstate;

	-- release time of each packet   F1  F2  F3  F4  F5
	-- (minizinc output) and packet
	-- size (minizinc input)
  	constant pkt_start : ivector := (26,  0,  0, 26, 0);
  	constant pkt_size  : ivector := ( 6, 14,  7,  9, 5);

begin
	reset <= '1', '0' after 15 ns;

    clocks_router: for i in 0 to NB_ROUTERS-1 generate
          clock(i) <= not clock(i) after 0.5 ns; -- TODO: freq definition
    end generate clocks_router;

	noc1: Entity work.NOC
	generic map(  X_ROUTERS => X_ROUTERS,
		          Y_ROUTERS => Y_ROUTERS)
	port map(
		clock         => clock,
		reset         => reset,
		clock_rxLocal => clock_rx,
		rxLocal       => rx,
		data_inLocal  => data_in,
		credit_oLocal => credit_o,
		clock_txLocal => clock_tx,
		txLocal       => tx,
		data_outLocal => data_out,
		credit_iLocal => credit_i);

    clock_rx(0) <= clock(0); 

    reset <= '1', '0' after 15 ns;

	-- delta cycles impl.
	cycle_counter : process (clock(0), reset) begin
		if rising_edge(clock(0)) and reset = '0' then 
			cycles <= cycles + 1;
		end if;
	end process;

	-- reset packet states 
	-- TODO: replace nanoseconds by cycles if freq != 0.5 ns
    reset_pkt_states: for i in 0 to NUM_PACKETS-1 generate
		pkt_state(i) <= WAITING, 
			HEADER  after (pkt_start(i) + 1) * 1 ns,
			SIZE    after (pkt_start(i) + 2) * 1 ns, 
			PAYLOAD after (pkt_start(i) + 3) * 1 ns,
			DONE    after (pkt_start(i) + 3 + pkt_size(i)) * 1 ns;
    end generate reset_pkt_states;

	-- TODO: injection process 
	

end TB;
