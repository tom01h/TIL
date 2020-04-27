#include "Vadd.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

vluint64_t main_time;
VerilatedVcdC* tfp;
Vadd* verilator_top;

vluint64_t vcdstart = 0;
vluint64_t vcdend = vcdstart + 300000;

int main(int argc, char **argv, char **env) {
  
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  main_time = 0;
  tfp = new VerilatedVcdC;
  verilator_top = new Vadd;
  verilator_top->trace(tfp, 99); // requires explicit max levels param
  tfp->open("tmp.vcd");

  for(unsigned int i=0; i<(1<<8); i++){
    for(unsigned int j=0; j<(1<<8); j++){
      verilator_top->a = i;
      verilator_top->b = j;
      verilator_top->eval();
      if(verilator_top->s == i+j){
        printf("PASSED : %04x + %04x = %05x\n",i,j,i+j);
      }else{
        printf("FAILED : %04x + %04x = %05x != %05x\n",i,j,i+j, verilator_top->s);
      }
    }
  }

  delete verilator_top;
  tfp->close();
  
  exit(0);
}
