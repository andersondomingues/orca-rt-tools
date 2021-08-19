library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use work.HermesPackage.all;
use work.standards.all;
use STD.TEXTIO.all;

entity Injector is 
generic(x_ROUTERS: integer := 3;
        Y_ROUTERS: integer := 2 );
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
  constant MAX_INT : integer := 100000; -- prevent huge simulations from crashing 

  -- elapsed cycles
  signal cycles : integer := 0; 

  -- packet structure, integer values cannot exceed MAX_INT
  type packet is record 
    start, size, src, tgt, deadline :  integer range 0 to MAX_INT; 
  end record;
    
  type tpacket is array(natural range <>) of packet;

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

  -- TODO: 
  constant tp : tpacket := (
  -- start  size  src tgt deadline 
    ( 0,    14,    0,  1,    55),  
    (26,     6,    0,  1,    55),  
    (30,    20,    0,  3,    55)
  );

  -- packet transmission - one FSM per packet
  type pckstate_t is (WAITING, HEADER, SIZE, PAYLOAD, DONE);
  type pckstate is array(0 to tp'high) of pckstate_t;
  signal pkt_state : pckstate;

  signal pkt_cont : INTEGER := 0;

begin
   
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
  process(clock, reset) begin
    for i in 0 to tp'high loop -- iterate on packets
	  if reset = '1' then 
	    pkt_state(i) <= WAITING;
	    tx <= '0';  -- TODO:
	    data_out <= (others => 'Z');

	  elsif rising_edge(clock) then

		case pkt_state(i) is

		   when WAITING =>  -- must verify tx, to avoid superposed packets --
              -- and tx = '0'    << remove this check (read from output, TODO)
              if cycles >= tp(i).start and credit_i = std_logic'high then  
                pkt_state(i) <= HEADER; 
                data_out <=  conv_std_logic_vector(tp(i).src, METADEFLIT) &
                               RouterAddress(tp(i).tgt);    
                                 -- ADDED SOURCE IN THE 16 MORE SIGNIFICAT BITS
                tx <= std_logic'high;
              end if;

            when HEADER =>
              if credit_i = std_logic'high then    
                pkt_state(i) <= SIZE; 
                pkt_cont <= tp(i).size;  -- store the packet size
                data_out <=  conv_std_logic_vector(tp(i).size, TAM_FLIT);
		      end if;

            when SIZE =>  
              if credit_i = std_logic'high then   
                pkt_state(i) <= PAYLOAD;
                pkt_cont <= pkt_cont - 1;
                data_out <= tp(i).size + 1 
                  - conv_std_logic_vector(pkt_cont, TAM_FLIT); -- ** cont_size (best)
              end if;   
		                                        
            when PAYLOAD =>
              if pkt_cont > 0 and credit_i = std_logic'high then   
                pkt_cont <= pkt_cont - 1;
                data_out <= tp(i).size + 1 - conv_std_logic_vector(pkt_cont, TAM_FLIT);
              elsif pkt_cont = 0 and credit_i = std_logic'high then
                pkt_state(i) <= DONE;
                tx <= std_logic'low;
				data_out <= (others => 'Z'); -- flag data_in as don't care
              end if;

            when others => null; -- never reaches DONE

		  end case; 
      end if;
    end loop;
  end process;
    
end InjectorBehavior;
