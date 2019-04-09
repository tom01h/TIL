#include <systemc.h>

SC_MODULE(sc_top)
{
  //Ports
  sc_in  <bool>         clk;
  sc_in  <bool>         rst;
  sc_in  <bool>         start;
  sc_out <bool>         last;
  sc_out <sc_uint<32> > wa;
  sc_out <sc_uint<32> > ia;

  //Thread Declaration
  void loop();

  //Constructor
  SC_CTOR(sc_top)
  {
    SC_CTHREAD(loop,clk.pos());
    reset_signal_is(rst,true);
  }
};
