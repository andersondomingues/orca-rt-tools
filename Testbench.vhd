library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use work.HermesPackage.all;
use work.standards.all;
use STD.TEXTIO.all;

entity Testbench is
  generic(X_ROUTERS: integer := 2;
          Y_ROUTERS: integer := 2 );
end;

architecture TB of Testbench is

  constant NUM_ROUTERS : integer :=  X_ROUTERS * Y_ROUTERS;

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

  function CONV_HEX( int: integer ) return string is         
    variable str: string(1 to 1);
  begin
    case(int) is  
      when 0 => str := "0";
      when 1 => str := "1";
      when 2 => str := "2";
      when 3 => str := "3";
      when 4 => str := "4";
      when 5 => str := "5";
      when 6 => str := "6";
      when 7 => str := "7";
      when 8 => str := "8";
      when 9 => str := "9";
      when 10 => str := "A";
      when 11 => str := "B";
      when 12 => str := "C";
      when 13 => str := "D";
      when 14 => str := "E";
      when 15 => str := "F";
      when others =>  str := "U";
    end case;
    return str;
  end CONV_HEX; 
  ----------------------------------------------------------------------------

  signal reset : std_logic;
  signal clock_rx : std_logic_vector((NUM_ROUTERS-1) downto 0) := (others=>'0');
  signal rx, credit_o: std_logic_vector((NUM_ROUTERS-1) downto 0) := (others=>'0');
  signal clock_tx, tx, credit_i: std_logic_vector((NUM_ROUTERS-1) downto 0);
  signal data_in, data_out : arrayNrot_regflit((NUM_ROUTERS-1) downto 0);

  signal cycles : integer := 0; -- elapsed (delta) cycles

  -- Notes:
  -- (a) a source cannot send packets to itself
  -- (b) TODO: TIME MUST BE MONOTONIC (not sure now)
  type packet is record 
    start, size, src, tgt, deadline :  integer range 0 to 255; --TODO: range up to hyperiod
  end record;
    
  type tpacket is array(natural range <>) of packet;

  constant tp : tpacket := (
  -- start  size  src tgt deadline 
    ( 0,    14,    0,  1,    55),  
    ( 0,     7,    2,  3,    55),  
    ( 0,     5,    3,  0,    55),  
    (12,     8,    1,  0,    55),  
    (26,     9,    2,  1,    55),  
    (26,     6,    0,  1,    55),  
    (30,    20,    0,  3,    55)
  );

  -- packet transmission - one FSM per packet
  type pckstate_t is (WAITING, HEADER, SIZE, PAYLOAD, DONE);
  type pckstate is array(0 to tp'high) of pckstate_t;
  signal pkt_state : pckstate;

  -- vector of integers (one entry per packet)
  type ivector is array(0 to tp'high) of INTEGER range 0 to 255;
  signal pkt_used, pkt_cont: ivector;

  -- for debug purposes - output file ------------------------------------------
  file rcp_file : TEXT open WRITE_MODE is "rcp_packet.txt";
  type lines is array(0 to NUM_ROUTERS-1) of line;

  type flags is array(0 to NUM_ROUTERS-1) of integer;
  signal flag: flags := (others=>0);

begin
  reset <= '1', '0' after 5 ns;

  -- clock signals, goes to each router
  clocks_router: for i in 0 to NUM_ROUTERS-1 generate
    clock_rx(i) <=  not clock_rx(i) after 500 ps;   
  end generate clocks_router;

  -- enable all ports to receive data (no contention at destination)
  credit_i <= (others => '1');   

  noc1: Entity work.NOC
  generic map(  X_ROUTERS => X_ROUTERS,
                Y_ROUTERS => Y_ROUTERS)
  port map(
    clock=>clock_rx, reset=>reset,

    -- data that goes to the NoC, controlled by credit_o
    clock_rxLocal=>clock_rx, rxLocal=>rx,
    data_inLocal=>data_in, credit_oLocal=>credit_o,

    -- data reception from the NoC
    clock_txLocal => clock_tx, txLocal=>tx,
    data_outLocal=>data_out, credit_iLocal => credit_i
  );

  -- cycle counter process
  cycle_counter : process (clock_rx(0), reset) begin
    if rising_edge(clock_rx(0)) then
      if reset = '0' then 
        cycles <= cycles + 1;
      else 
        cycles <= 0;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  --  one FSM per packet!, according to the timestamps to start the transmission
  --  this process is reponsible for generating the traffic specified in tpacket
  ----------------------------------------------------------------------------
  process(clock_rx(0), reset) begin
    for i in 0 to tp'high loop
	  if reset = '1' then 
	    pkt_state(i) <= WAITING;
	    rx(tp(i).src) <= '0';  -- TODO:
	    data_in(tp(i).src) <= (others => 'Z');
	    pkt_used <= (others => 0);

	  elsif rising_edge(clock_rx(0)) then
		-- AVOID EFFECT OF PAST PACKET IN CURRENT PACKETS WITH THE SAME SOURCE ADDRESS
		if pkt_used(i) = 0 then   
		  case pkt_state(i) is

		    when WAITING =>  -- must verify rx, to avoid superposed packets --
              if cycles >= tp(i).start and rx(tp(i).src) = '0' 
                and credit_o(tp(i).src) = '1' then  
                pkt_state(i) <= HEADER; 
                data_in(tp(i).src) <=  conv_std_logic_vector(tp(i).src, METADEFLIT) &
                                       RouterAddress(tp(i).tgt);    
                                       -- ADDED SOURCE IN THE 16 MORE SIGNIFICAT BITS
                rx(tp(i).src) <= '1';
              end if;

            when HEADER =>
              if credit_o(tp(i).src)='1' then    
                pkt_state(i) <= SIZE; 
                pkt_cont(i) <= tp(i).size;  -- store the packet size
                data_in(tp(i).src) <=  conv_std_logic_vector( tp(i).size, TAM_FLIT);
		      end if;

            when SIZE =>  
              if credit_o(tp(i).src)='1' then   
                pkt_state(i) <= PAYLOAD;
                pkt_cont(i) <= pkt_cont(i)-1;
                data_in(tp(i).src) <= tp(i).size + 1 
                  - conv_std_logic_vector(pkt_cont(i), TAM_FLIT); -- ** cont_size (best)
              end if;   
		                                        
            when PAYLOAD =>
              if pkt_cont(i) > 0 and credit_o(tp(i).src) = '1' then   
                pkt_cont(i) <= pkt_cont(i) - 1;
                data_in(tp(i).src) <= tp(i).size + 1
                  - conv_std_logic_vector(pkt_cont(i), TAM_FLIT);
              elsif pkt_cont(i) = 0 and credit_o(tp(i).src) = '1' then
                pkt_state(i) <= DONE;
                rx(tp(i).src) <= '0';
				data_in(tp(i).src) <= (others => 'Z'); -- flag data_in as don't care
                pkt_used(i) <= 1;  -- mark packet as 'used'
              end if;

            when others => null; -- never reaches DONE

		  end case; 
        end if;
      end if;
    end loop;
  end process;

  ----------------------------------------------------------------------------
  -- log file
  ----------------------------------------------------------------------------
  process(clock_rx(0), reset)
    variable my_line: lines;
  begin
    for r in 0 to NUM_ROUTERS-1 loop
      if rising_edge(clock_rx(0)) then
        if tx(r)='1' and credit_i(r)='1' then
          if flag(r)=0 then
            write(my_line(r), 
              "From: " & integer'image(CONV_INTEGER(data_out(r)(15 downto 8))) & 
              " To: "  & integer'image(r) & " at stamp: " & integer'image(cycles) & " P: " );
          end if;
          write(my_line(r), CONV_HEX(CONV_INTEGER(data_out(r)(15 downto 12))) &
            CONV_HEX(CONV_INTEGER(data_out(r)(11 downto  8))) &
            CONV_HEX(CONV_INTEGER(data_out(r)( 7 downto  4))) &
            CONV_HEX(CONV_INTEGER(data_out(r)( 3 downto  0))) & " " );
          flag(r) <= 1;
        end if;
      end if;

      -- packeted ended and I can write it to the outoup file
      if tx(r)='0' and flag(r)=1 then    
        write(my_line(r), " [Final stamp: " & integer'image(cycles) & "]" );
        writeline(rcp_file, my_line(r));
        flag(r) <= 0;
      end if;
    end loop;
  end process;

  ----------------------------------------------------------------------------
  -- deadline assertion 
  ----------------------------------------------------------------------------
  deadline_checking: for i in 0 to tp'high generate
  process (clock_rx(0), reset) begin 
    if rising_edge(clock_rx(0)) and reset = '0' then
      if pkt_state(i) = DONE then
        -- TODO: fix conditional assert
        assert pkt_state(i) = WAITING report "DEADLINE MISSED" severity warning;
      end if;
    end if;
  end process;
  end generate deadline_checking;

end TB;

