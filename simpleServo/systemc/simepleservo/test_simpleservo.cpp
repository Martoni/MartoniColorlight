#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>

/* Clock frequency in kHz */
#define CLK_FREQ 95000
#define DEBOUNCE_PER_MS 20

#define BASE_TIME_NS ((1000*1000)/(CLK_FREQ*2))
int base_time = 0;

