/******************************************************************************
 * This file is part of project ORCA RT Tools. More information on the project
 * can be found at the following repositories at GitHub's website.
 *
 * http://https://github.com/andersondomingues/orca-rt-tools
 *
 * Copyright (C) 2018-2021 Anderson Domingues, <ti.andersondomingues@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA. 
******************************************************************************/
#include <iostream>
#include <vector>
#include "Main.hpp"
#include "DotToZinc.hpp"
#include "DotToRecord.hpp"

void printUsage(){
	std::cout << "Usage: rt-tools.exe <command> <params>" << std::endl;
	std::cout << "Available commands:" << std::endl;
	std::cout << "\t \"z\" Generate minizinc file from .dot graph" << std::endl;
	std::cout << "\t \"r\" Generate vhdl record from .dot graph" << std::endl;
	std::cout << std::endl << std::endl;
}

int main(int argc, char** argv){
	
	if(argc <= 1){
		printUsage();
		return 0;
	}

	std::vector<std::string>* argvector = new std::vector<std::string>();

	for(int i = 0; i < argc; i++)
		*argvector->push_back(std::string(argv[i]));

	switch(argv[1]){
		case 'z': dotToZinc(argvector); break;
		case 'r': dotToRecord(argvector); break;
		default: printUsage();
	}
}
