extern volatile uint32_t * CACC_REGISTER;
extern volatile uint32_t * CACC_COUNTER1;
extern volatile uint32_t * CACC_COUNTER2;


void set_cacc(uint32_t v);
uint32_t get_cacc();

void set_counter_1(uint32_t v);
uint32_t get_counter_1();

void set_counter_2(uint32_t v);
uint32_t get_counter_2();