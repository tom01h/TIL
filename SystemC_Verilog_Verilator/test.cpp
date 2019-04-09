#include "systemc.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "sc_top.h"
#include "Vtop.h"

sc_clock clk ("clk", 10, SC_NS);

sc_signal <bool>         rst;
sc_signal <bool>         start;
sc_signal <bool>         last;
sc_signal <sc_uint<32> > wa;
sc_signal <sc_uint<32> > ia;

vluint64_t main_time = 0;
vluint64_t vcdstart = 0;
vluint64_t vcdend = vcdstart + 300000;

VerilatedVcdC* tfp;
Vtop* verilator_top;

void eval()
{
  // negedge clk /////////////////////////////
  verilator_top->clk = !clk;

  verilator_top->eval();
  sc_start(5, SC_NS);

  if((main_time>=vcdstart)&((main_time<vcdend)|(vcdend==0)))
    tfp->dump(main_time);
  main_time += 5;

  // posegedge clk /////////////////////////////
  verilator_top->clk = !clk;

  verilator_top->eval();
  sc_start(5, SC_NS);

  //          verilog -> SystemC
  start = verilator_top->last;
  //          SystemC -> verilog
  verilator_top->sc_ia = ia.read();
  verilator_top->sc_wa = wa.read();
  verilator_top->sc_last = last.read();

  if((main_time>=vcdstart)&((main_time<vcdend)|(vcdend==0)))
    tfp->dump(main_time);
  main_time += 5;

  return;
}

int sc_main(int argc, char **argv) {

  // Verilator setup /////////////////////////////
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;
  verilator_top = new Vtop;
  verilator_top->trace(tfp, 99); // requires explicit max levels param
  tfp->open("tmp.vcd");
  main_time = 0;

  // SystemC setup /////////////////////////////
  sc_top U_sc_top("U_sc_top");
  U_sc_top.clk(clk);
  U_sc_top.rst(rst);
  U_sc_top.start(start);
  U_sc_top.last(last);
  U_sc_top.wa(wa);
  U_sc_top.ia(ia);

  // SystemC setup (wave) /////////////////////////////
  sc_trace_file *trace_f;
 
  trace_f = sc_create_vcd_trace_file( "sc" );
  trace_f->set_time_unit( 1.0, SC_NS );
 
  sc_trace( trace_f, clk, "clk" );
  sc_trace( trace_f, rst, "rst" );
  sc_trace( trace_f, start, "start" );
  sc_trace( trace_f, last, "last" );
  sc_trace( trace_f, wa, "wa" );
  sc_trace( trace_f, ia, "ia" );

  // initial begin /////////////////////////////
  rst = 1;
  verilator_top->rst = 1;
  verilator_top->clk = 1;
  verilator_top->eval();
  sc_start(5, SC_NS);
  main_time += 5;

  eval();eval();
  rst = 0;
  verilator_top->rst = 0;
  eval();eval();
  verilator_top->start = 1;
  eval();
  verilator_top->start = 0;

  while(!last){
    eval();
  }
  eval();eval();
  verilator_top->rst = 1;
  eval();eval();

  // $finish; end /////////////////////////////
  delete verilator_top;
  tfp->close();
  return 0;
}
