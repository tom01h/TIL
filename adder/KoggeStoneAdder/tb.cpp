#include "Vksa.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

vluint64_t main_time;
VerilatedVcdC* tfp;
Vksa* verilator_top;

vluint64_t vcdstart = 0;
vluint64_t vcdend = vcdstart + 300000;

void eval()
{
  verilator_top->clk = 0;
  verilator_top->eval();

  if((main_time>=vcdstart)&((main_time<vcdend)|(vcdend==0)))
    tfp->dump(main_time);
  main_time += 5;

  verilator_top->clk = 1;
  verilator_top->eval();

  if((main_time>=vcdstart)&((main_time<vcdend)|(vcdend==0)))
    tfp->dump(main_time);
  main_time += 5;

  return;
}

int main(int argc, char **argv, char **env) {
  
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  main_time = 0;
  tfp = new VerilatedVcdC;
  verilator_top = new Vksa;
  verilator_top->trace(tfp, 99); // requires explicit max levels param
  tfp->open("tmp.vcd");

  for(unsigned int i=0; i<(1<<8); i++){
    for(unsigned int j=0; j<(1<<8); j++){
      verilator_top->a = i;
      verilator_top->b = j;
      eval();
      int exp = i+j;
      if(verilator_top->s == exp){
        printf("PASSED : %04x + %04x = %05x\n",i,j,exp);
      }else{
        printf("FAILED : %04x + %04x = %05x != %05x\n",i,j,exp, verilator_top->s);
      }
    }
  }

  delete verilator_top;
  tfp->close();
  
  exit(0);
}
