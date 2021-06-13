/******************************************************************************
 * This file is part of project ORCA. More information on the project
 * can be found at the following repositories at GitHub's website.
 *
 * http://https://github.com/andersondomingues/orca-sim
 * http://https://github.com/andersondomingues/orca-software
 * http://https://github.com/andersondomingues/orca-mpsoc
 * http://https://github.com/andersondomingues/orca-tools
 * http://https://github.com/andersondomingues/orca-modeling
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
#include "main.hpp"
#include "DotToZinc.hpp"

void printUsage(){
	std::cout << "Usage: rt-tools.exe <cmd> <params>" << std::endl;
	std::cout << "Available commands:" << std::endl;
	std::cout << "\t dot2zinc Generate minizinc file from .dot graph" << std::endl;
	std::cout << std::endl << std::endl;
}

int main(int argc, char** argv){
	
	if(argc <= 1){
		printUsage();
		return 0;
	}
	
	if(strcmp(argv[1], "-d2z"){
		dotToZinc(argc, &argv[2]);
	}else{
		printUsage();
	}
}