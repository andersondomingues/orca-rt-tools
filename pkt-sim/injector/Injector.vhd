library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use work.HermesPackage.all;
use work.standards.all;
use work.txt_util.all;
use STD.TEXTIO.all;

entity Injector is 
generic(x_ROUTERS: integer := 3;
        Y_ROUTERS: integer := 2;
        PE_NUM: integer);
port (
  clock    : in  std_logic;
  reset    : in  std_logic;

  clock_tx : out  std_logic;  --rx ports attach to tx ports of routers
  tx       : out  std_logic;
  data_out : out  regflit;
  credit_i : in std_logic
);
end Injector;

architecture InjectorBehavior of Injector is

  -- prevents long time simulations from crashing 
  constant MAX_INT : integer := 100000; 

  -- converts pe address from numeric to xy format
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

  -- elapsed cycles
  signal cycles : integer := 0; 

  -- packet structure, integer values cannot exceed MAX_INT
  type packet_t is record 
    start, size, target, deadline :  integer range 0 to MAX_INT; 
  end record;

  -- pkt state
  type packet_state_t is (
    WAITING, -- load pkt info into input signals and wait until release time
    HEADER,  -- inject first flit
    SIZE,    -- inject second flit 
    PAYLOAD  -- inject remaining flits
  );
    
  -- current loaded packet (from file)
  signal pkt : packet_t; 
  signal pkt_state : packet_state_t;

  -- remaining payload flits
  signal pkt_cont : INTEGER := 0;

begin

  -- clock_tx (?) -- TODO
  clock_tx <= clock;

  -- RESET and CYCLE COUNTER
  proc_reset: process (clock, reset) begin
    if rising_edge(clock) then
      if reset = std_logic'high then
        cycles <= 0;
      else
        cycles <= cycles + 1;
      end if;
    end if;
  end process proc_reset;

  --flow generation
  process(clock, reset) 
    variable v_line  : LINE;
    variable v_space : CHARACTER;
    file v_text  : TEXT;

    variable d_start : INTEGER;
    variable d_size  : INTEGER;
    variable d_target : INTEGER;
    variable d_deadline : INTEGER;

    -- file manip variables
    variable packet_loaded_already : std_logic := '0';
    constant pe_file : string := "packets/" & str(PE_NUM, 10) & ".txt";
  begin
    if reset = '1' then 
	  pkt_state <= WAITING;
	  tx <= '0';
	  data_out <= (others => 'Z');
	elsif rising_edge(clock) then

	  case pkt_state is
        -- WAITING: load next packet from file into pkt record (if any)
        -- (1) there is no more packets to load, go to DONE
        -- (2) the next packet was loaded, periodically check on timer,
        --     release that packet's header
	    when WAITING =>
          -- load packet from file if any
          if packet_loaded_already = '0' then   
            file_open(v_text, pe_file, read_mode);
			readline(v_text, v_line);
            read(v_line, d_start);   read(v_line, v_space);
            read(v_line, d_size);    read(v_line, v_space);
            read(v_line, d_target);  read(v_line, v_space);
            read(v_line, d_deadline); 
            file_close(v_text);

            packet_loaded_already := '1';

            pkt.start <= d_start;
            pkt.size <= d_size;
            pkt.target <= d_target;
            pkt.deadline <= d_deadline;

          end if;
          -- release first flit (header)
          if cycles >= pkt.start and credit_i = std_logic'high then  
            pkt_state <= HEADER; 
            data_out <= conv_std_logic_vector(pkt.target, METADEFLIT) &
              RouterAddress(pkt.target);    
            tx <= std_logic'high; --enable tx
          else 
            tx <= std_logic'low;
			data_out <= (others => 'Z'); -- flag data_in as don't care
          end if;
        
        -- HEADER: if enough credit, send the next packet, wait otherwise 
        when HEADER =>
          if credit_i = std_logic'high then    
            pkt_state <= SIZE; 
            pkt_cont <= pkt.size;  -- store the packet size
            data_out <=  conv_std_logic_vector(pkt.size, TAM_FLIT);
		  end if;

        -- SIZE: transmit payload flits if enought credit, wait otherwise
        when SIZE =>  
          if credit_i = std_logic'high then   
            pkt_cont <= pkt_cont - 1;
            data_out <= pkt.size + 1 - conv_std_logic_vector(pkt_cont, TAM_FLIT);

            if pkt_cont = 0 then
              packet_loaded_already := '0';
              pkt_state <= WAITING; 
            end if;
          end if;

        -- DONE: no more flits to send
        when others => null;
      end case; 
    end if;
  end process;
    
end InjectorBehavior;
