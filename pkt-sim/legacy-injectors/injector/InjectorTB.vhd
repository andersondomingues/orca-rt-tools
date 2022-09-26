library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use work.HermesPackage.all;
use work.standards.all;
use work.InjectorPackage.all;
use STD.TEXTIO.all;

entity InjectorTB is 
  generic(X_ROUTERS: integer := 2;
          Y_ROUTERS: integer := 2 );
end InjectorTB;

architecture InjectorTBBehavior of InjectorTB is

  constant NUM_ROUTERS : integer :=  X_ROUTERS * Y_ROUTERS;

  type packetArray is array((NUM_ROUTERS-1) downto 0) of packet_t;
  type packetStateArray is array((NUM_ROUTERS-1) downto 0) of packet_state_t;

  signal clock : std_logic := '0';
  signal reset : std_logic;

  -- arrays follow the same direction as the injectors, routers follow the opposite direction
  -- (outputs of injectors match the inputs of routers)
  signal clock_rxArray, rxArray, credit_oArray: 
    std_logic_vector((NUM_ROUTERS-1) downto 0) := (others=>'0');
  signal clockArray, clock_txArray, txArray, credit_iArray:
    std_logic_vector((NUM_ROUTERS-1) downto 0);
  signal data_inArray, data_outArray : arrayNrot_regflit((NUM_ROUTERS-1) downto 0);
  signal pkt_oArray : packetArray;
  signal pkt_state_oArray : packetStateArray;

begin

  reset <= '1', '0' after 1 ns;
  clock <= not clock after 500 ps;
 
  -- generate clock for injector transmission
  clock_tx_gen : for i in 0 to NUM_ROUTERS-1 generate
    clock_txArray(i) <= clock;
    clockArray(i) <= clock;
  end generate;

  -- enable unlimited credit (disable contention in routers-to-tb communication)
  credit_oArray <= (others => '1');

  -- generate array of injectors
  injectors_gen: for i in 0 to NUM_ROUTERS-1 generate

  Injector: Entity work.Injector
  generic map(
    X_ROUTERS => X_ROUTERS,
    Y_ROUTERS => Y_ROUTERS,
    PE_NUM => i
  )
  port map(
    clock => clock,
    reset => reset,
  
    clock_tx => clock_txArray(i), -- arrays
    tx => txArray(i),
    data_out => data_outArray(i),
    credit_i => credit_iArray(i),
    pkt_o => pkt_oArray(i),
    pkt_state_o => pkt_state_oArray(i)
  );
  end generate;

  noc : Entity work.NOC
  generic map(
    X_ROUTERS => X_ROUTERS,
    Y_ROUTERS => Y_ROUTERS
  )
  port map(
    clock => clockArray,
    reset => reset,
  
    clock_rxLocal => clock_txArray,
    rxLocal => txArray,
    data_inLocal => data_outArray,
    credit_oLocal => credit_iArray,

    clock_txLocal => clock_rxArray,
    txLocal => rxArray,
    data_outLocal => data_inArray,
    credit_iLocal => credit_oArray
  );
 
end InjectorTBBehavior;
