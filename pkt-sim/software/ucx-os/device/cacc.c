#include <ucx.h>

volatile uint32_t* CACC_REGISTER = (volatile uint32_t *)(0x20000028);
volatile uint32_t* CACC_COUNTER1 = (volatile uint32_t *)(0x2000002C);
volatile uint32_t* CACC_COUNTER2 = (volatile uint32_t *)(0x20000030);

void set_cacc(uint32_t v){
  *CACC_REGISTER = v;
}

uint32_t get_cacc(){
  return *CACC_REGISTER;
}

void set_counter_1(uint32_t v){
  *CACC_COUNTER1 = v;
}

uint32_t get_counter_1(){
  return *CACC_COUNTER1;
}

void set_counter_2(uint32_t v){
  *CACC_COUNTER2 = v;
}

uint32_t get_counter_2(){
  return *CACC_COUNTER2;
}