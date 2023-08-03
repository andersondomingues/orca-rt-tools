package orca_pkg;

`include "orca_defs.h"

typedef logic[`BUS_WIDTH-1:0] word_t;
typedef logic[(`BUS_WIDTH >> 2)-1:0] hword_t;
typedef logic[(`BUS_WIDTH << 2)-1:0] dword_t;
typedef logic[7:0] ubyte_t;

const ubyte_t[7:0] BLUE      = "\033[94m";
const ubyte_t[7:0] CYAN      = "\033[96m";
const ubyte_t[7:0] GREEN     = "\033[92m";
const ubyte_t[7:0] YELLOW    = "\033[93m";
const ubyte_t[7:0] RED       = "\033[91m";
const ubyte_t[7:0] BOLD      = "\033[1m";
const ubyte_t[7:0] UNDERLINE = "\033[4m";
const ubyte_t[7:0] HEADER    = "\033[95m";
const ubyte_t[7:0] ENDL      = "\033[0m";

function void cdisplay(string s, ubyte_t[7:0] c);
  $display("%0s%0s%0s", c, s, ENDL);
endfunction

endpackage