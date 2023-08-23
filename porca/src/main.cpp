#include <iostream>

#include <vector>
#include "../include/main.h"
#include "../include/tty.h"

std::string_view get_option(
    const std::vector<std::string_view>& args, 
    const std::string_view& option_name) {
    for (auto it = args.begin(), end = args.end(); it != end; ++it) {
        if (*it == option_name)
            if (it + 1 != end)
                return *(it + 1);
    }
    
    return "";
}



int main(int argc, char** argv){
  
  //prints the blue whale 
  for(const auto& s: WELCOME_MESSAGE)
    std::cout << tty::b_blue << s << tty::a_reset << std::endl;


  // add command line options to a string view vector
  const auto options = std::vector<std::string_view>(argv + 1, argv + argc);

  // list all options
  for (const auto opt: options){
    if (opt[0] == '-') {
      std::cout << tty::b_blue <<  tty::blue << "text" << tty::a_reset << std::endl;
    }
  }



}