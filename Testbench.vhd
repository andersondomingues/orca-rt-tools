library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use work.HermesPackage.all;
use work.standards.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

entity Testbench is
    generic(X_ROUTERS: integer := 2;
    	    Y_ROUTERS: integer := 2 );
end;

architecture TB of Testbench is

	constant NUM_ROUTERS : integer :=  X_ROUTERS * Y_ROUTERS;

	-- TODO: put it into a package
	function RouterAddress(router: integer) return std_logic_vector is
		variable pos_x, pos_y : regquartoflit; 
		variable addr : regmetadeflit; 
		variable aux  : integer;
	begin 
		aux := (router/X_ROUTERS);
		pos_x := conv_std_logic_vector((router mod X_ROUTERS),QUARTOFLIT);
		pos_y := conv_std_logic_vector(aux,QUARTOFLIT); 
		addr := pos_x & pos_y;
		return addr;
	end RouterAddress;

	signal clock : std_logic_vector((NUM_ROUTERS-1) downto 0) := (others=>'0');
	signal reset : std_logic;
	signal clock_rx, rx, credit_o: std_logic_vector((NUM_ROUTERS-1) downto 0);
	signal clock_tx, tx, credit_i: std_logic_vector((NUM_ROUTERS-1) downto 0);
	signal data_in, data_out : arrayNrot_regflit((NUM_ROUTERS-1) downto 0);

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
	signal pkt_test  : std_logic_vector(NUM_PACKETS-1 downto 0);

	--                                  F1  F2  F3  F4  F5
  	constant pkt_start    : ivector := (26,  0,  0, 26,  0); -- release cycle
  	constant pkt_size     : ivector := ( 6, 14,  7,  9,  5); -- payload size
	constant pkt_source   : ivector := ( 0,  0,  2,  2,  3); -- source router #
	constant pkt_target   : ivector := ( 1,  0,  3,  1,  0); -- target router #
	constant pkt_deadline : ivector := (55, 55, 55, 55, 55); -- max tx tolerance

begin
	reset <= '1', '0' after 5 ns;

	-- TODO: ??
    clocks_router: for i in 0 to NUM_ROUTERS-1 generate
          clock(i) <= not clock(i) after 0.5 ns; -- 500 ps
    end generate clocks_router;

	credit_o <= (others => '1');

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

	clock_rx <= clock; 

	-- cycle counter process
	cycle_counter : process (clock(0), reset) begin
		if rising_edge(clock(0)) then
			if reset = '0' then 
				cycles <= cycles + 1;
			else 
				cycles <= 0;
			end if;
		end if;
	end process;

	-- packet state machine processes
    reset_pkt_states: for i in 0 to NUM_PACKETS-1 generate
	process (clock(0), reset) begin
		if rising_edge(clock(0)) and reset = '0' then
			if cycles < pkt_start(i) then
				pkt_state(i) <= WAITING;			
			elsif cycles = pkt_start(i) then
				pkt_state(i) <= HEADER;
			elsif pkt_state(i) = HEADER then
				pkt_state(i) <= SIZE;
			elsif pkt_state(i) = SIZE then
				pkt_state(i) <= PAYLOAD;
			elsif pkt_state(i) = PAYLOAD 
				and cycles >= (pkt_start(i) + 3 + pkt_size(i)) then
					pkt_state(i) <= DONE;
			end if;
		end if;
	end process;
    end generate reset_pkt_states;

	-- data injection
    rx_procs: for i in 0 to NUM_ROUTERS-1 generate
	process (clock(0), reset) 
		variable is_transmitting : boolean;
	begin	
		if rising_edge(clock(0)) and reset = '0' then

			is_transmitting := false;

			for k in 0 to NUM_PACKETS-1 loop
				if pkt_source(k) = i then -- pkt source is the current router
					case pkt_state(k) is
					when HEADER => 
						data_in(i) <= (data_in(0)'range => '0') 
							+ RouterAddress(pkt_target(i));
						is_transmitting := true;
					when SIZE =>
						data_in(i) <= std_logic_vector(
							to_unsigned(pkt_size(k), 
								data_in(pkt_size(k))'length));
						is_transmitting := true;
					when PAYLOAD =>
						data_in(i) <= conv_std_logic_vector(
							cycles, data_in(i)'length);				
						is_transmitting := true;
					when others => -- intentionally left empty
					end case;
				end if;
			end loop;

			if is_transmitting and credit_o(i) = '1' then
				rx(i) <= '1';				
			else 
				rx(i) <= '0';
				data_in(i) <= (others => 'Z');
			end if;

		end if;
	end process;
    end generate rx_procs;
	
	-- deadline assertion 
	deadline_checking: for i in 0 to NUM_PACKETS-1 generate
	process (clock(0), reset) begin	
		if rising_edge(clock(0)) and reset = '0' then
			if pkt_state(i) = DONE then
				-- TODO: fix conditional assert
				assert pkt_state(i) = WAITING report "DEADLINE MISSED" severity warning;
			end if;
		end if;
	end process;
	end generate deadline_checking;

end TB;
