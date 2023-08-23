#include <string>

#ifndef NO_TTY_COLORS

namespace tty {
  const std::string_view black   { "\033[30m" };
  const std::string_view red     { "\033[31m" };
  const std::string_view green   { "\033[32m" };
  const std::string_view yellow  { "\033[33m" };
  const std::string_view blue    { "\033[34m" };
  const std::string_view magenta { "\033[35m" };
  const std::string_view cyan    { "\033[36m" };
  const std::string_view white   { "\033[37m" };

  const std::string_view b_black   { "\033[40m" };
  const std::string_view b_red     { "\033[41m" };
  const std::string_view b_green   { "\033[42m" };
  const std::string_view b_yellow  { "\033[43m" };
  const std::string_view b_blue    { "\033[44m" };
  const std::string_view b_magenta { "\033[45m" };
  const std::string_view b_cyan    { "\033[46m" };
  const std::string_view b_white   { "\033[47m" };

  const std::string_view a_reset   { "\033[0m"  };
  const std::string_view a_bold    { "\033[1m"  };
  const std::string_view a_ul      { "\033[4m"  };
  const std::string_view a_inv     { "\033[7m"  };
  const std::string_view u_bold    { "\033[21m" };
  const std::string_view u_ul      { "\033[24m" };
  const std::string_view u_inv     { "\033[27m" };
}

#else




#endif

