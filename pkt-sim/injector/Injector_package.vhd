--------------------------------------------------------------------------
-- package com tipos basicos
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

package InjectorPackage is

  -- prevents long time simulations from crashing 
  constant MAX_INT : integer := 100000; 

	-- packet structure, integer values cannot exceed MAX_INT
  type packet_t is record 
    start, size, target, deadline :  integer range 0 to MAX_INT; 
  end record;

  -- pkt state
  type packet_state_t is (
    HEADER,  -- load pkt info into input signals inject first flit
    SIZE,    -- inject second flit 
    PAYLOAD, -- inject remaining flits
    DONE     -- no more packets to inject
  );

end InjectorPackage;
