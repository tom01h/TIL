#include "sim/Vadd.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <Python.h>

VerilatedVcdC* tfp;
Vadd* verilator_top;
vluint64_t main_time;

int c;

static PyObject *
add (PyObject *self, PyObject *args) {
  int a, b;
  // 送られてきた値をパース
  if(!PyArg_ParseTuple(args, "ii",&a, &b))
    return NULL;

  printf("%d + %d\n", a, b);

  verilator_top->a = a;
  verilator_top->b = b;

  verilator_top->clk = 0;
  verilator_top->eval();
  tfp->dump(main_time);
  main_time += 5;
  verilator_top->clk = 1;
  verilator_top->eval();
  tfp->dump(main_time);
  main_time += 5;

  //  c = a + b;
  c = verilator_top->s;

  return Py_BuildValue("i", c);
}

static PyObject *
ans (PyObject *self, PyObject *args) {
  verilator_top->clk = 0;
  verilator_top->eval();
  tfp->dump(main_time);
  main_time += 5;
  verilator_top->clk = 1;
  verilator_top->eval();
  tfp->dump(main_time);
  main_time += 5;
  delete verilator_top;
  tfp->close();
  return Py_BuildValue("i", c);
}

// メソッドの定義
static PyMethodDef TopMethods[] = {
  {"ans", (PyCFunction)ans, METH_NOARGS,  "top1: ans"},
  {"add", (PyCFunction)add, METH_VARARGS, "top2: add"},
  // 終了を示す
  {NULL, NULL, 0, NULL}
};

//モジュールの定義
static struct PyModuleDef toptmodule = {
  PyModuleDef_HEAD_INIT,
  "top",
  NULL,
  -1,
  TopMethods
};

// メソッドの初期化
PyMODINIT_FUNC PyInit_top (void) {
  //  Verilated::commandArgs(argc,argv);
  Verilated::traceEverOn(true);
  main_time = 0;
  tfp = new VerilatedVcdC;
  verilator_top = new Vadd;
  verilator_top->trace(tfp, 99); // requires explicit max levels param
  tfp->open("tmp.vcd");

  return PyModule_Create(&toptmodule);
}
