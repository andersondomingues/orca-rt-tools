library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use work.HermesPackage.all;
use work.InjectorPackage.all;
use work.standards.all;
use work.txt_util.all;
use STD.TEXTIO.all;

entity Injector is 
generic(x_ROUTERS: integer := 4;
        Y_ROUTERS: integer := 4;
        PE_NUM: integer);
port (
  clock    : in  std_logic;
  reset    : in  std_logic;

  clock_tx : out  std_logic;  --rx ports attach to tx ports of routers
  tx       : out  std_logic;
  data_out : out  regflit;
  credit_i : in std_logic;

  pkt_o : out packet_t;
  pkt_state_o : out packet_state_t
);
end Injector;

architecture InjectorBehavior of Injector is

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


    --variable ZERO : std_logic_vector(TAM_FLIT / 2 downto 0) := (others => '0');

    return addr;
  end RouterAddress;

  -- elapsed cycles
  signal cycles : integer := 0; 

  -- current loaded packet (from file)
  signal pkt : packet_t; 
  signal pkt_state : packet_state_t;

  -- remaining payload flits
  signal pkt_cont : INTEGER := 0;

begin

  clock_tx <= clock;
  pkt_o <= pkt;
  pkt_state_o <= pkt_state;

  -- RESET and CYCLE COUNTER
  proc_reset: process (clock, reset) begin
    if rising_edge(clock) then
      if reset = '1' then
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
    variable d_status : FILE_OPEN_STATUS := status_error;
    variable d_zero : INTEGER := 0;

    -- file manip variables
    variable packet_loaded_already : std_logic := '0';
    constant pe_file : string := "packets/" & str(PE_NUM, 10) & ".txt";
  begin
    if reset = '1' then 
	  pkt_state <= HEADER;
      
	elsif rising_edge(clock) then

	  case pkt_state is
        -- WAITING: load next packet from file into pkt record (if any)
        -- (1) there is no more packets to load, go to DONE
        -- (2) the next packet was loaded, periodically check on timer,
        --     release that packet's header
	    when HEADER =>
          -- load packet from file if any
          if packet_loaded_already = '0' then   
            if d_status /= open_ok then
              file_open(d_status, v_text, pe_file, read_mode);
            end if;

            if not endfile(v_text) then
			        readline(v_text, v_line);
              read(v_line, d_start);   read(v_line, v_space);
              read(v_line, d_size);    read(v_line, v_space);
              read(v_line, d_target);  read(v_line, v_space);
              read(v_line, d_deadline); 

              pkt.start <= d_start;
              pkt.size <= d_size;
              pkt.target <= d_target;
              pkt.deadline <= d_deadline;

              packet_loaded_already := '1';
            end if;
          end if;

          -- release first flit (header)
          if cycles >= d_start and packet_loaded_already = '1' then
            packet_loaded_already := '0';
            pkt_state <= HEADER2;
          end if;
  
          -- HEADER: if enough credit, send the next packet, wait otherwise 
        when HEADER2 =>
          if credit_i = '1' then    
            pkt_state <= SIZE; 
            pkt_cont <= 0;  -- store the packet size
          end if;

        -- HEADER: if enough credit, send the next packet, wait otherwise 
        when SIZE =>
          if credit_i = '1' then    
            pkt_state <= PAYLOAD; 
            pkt_cont <= 0;  -- store the packet size
          
		    end if;

        -- SIZE: transmit payload flits if enought credit, wait otherwise
        when PAYLOAD =>  
          if credit_i = '1' then  
            pkt_cont <= pkt_cont + 1; 
          end if;

          if pkt_cont = pkt.size -1 then
            if not endfile(v_text) then
              pkt_state <= HEADER;
              d_start := 999;
            else 
              pkt_state <= DONE;
            end if;
          end if;

        -- DONE: no more flits to send
        when others =>  null;

      end case; 
    end if;
  end process;

  data_out <= conv_std_logic_vector(0, METADEFLIT) & RouterAddress(pkt.target) when pkt_state=HEADER2 else
              conv_std_logic_vector(pkt.size, TAM_FLIT) when pkt_state=SIZE else
              conv_std_logic_vector(pkt_cont+1, TAM_FLIT) when pkt_state=PAYLOAD else
              (others => 'Z');

  tx <= '1'  when  credit_i = '1'  and (pkt_state=HEADER2 or pkt_state=SIZE or pkt_state=PAYLOAD) else
        '0';

    
end InjectorBehavior;
