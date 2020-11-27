#include "svdpi.h"
#include "dpiheader.h"

#define PY_SSIZE_T_CLEAN
#include <Python.h>

unsigned long long x;

static PyObject*
cc_init(PyObject *self, PyObject *args){
    unsigned long long seed;
    // 送られてきた値をパース
    if(!PyArg_ParseTuple(args, "K", &seed))
        return NULL;

    x = seed;

    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject*
cc_random(PyObject *self, PyObject *args) {
    int start, end, msk;
    unsigned int val;
    // 送られてきた値をパース
    if(!PyArg_ParseTuple(args, "iii", &start, &end, &msk))
        return NULL;
    
    do{
        x = x ^ (x << 13);
        x = x ^ (x >> 7);
        x = x ^ (x << 17);
        val = x & msk;
    }while(!((start <= val) && (val <= end)));

    return Py_BuildValue("I", val);
}

static PyObject*
c_init(PyObject *self, PyObject *args){
    unsigned long long seed;
    // 送られてきた値をパース
    if(!PyArg_ParseTuple(args, "K", &seed))
        return NULL;

    v_init(seed);

    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject*
c_random(PyObject *self, PyObject *args) {
    int start, end, msk;
    unsigned int val;
    // 送られてきた値をパース
    if(!PyArg_ParseTuple(args, "iii", &start, &end, &msk))
        return NULL;
    
    v_random(start, end, msk, &val);

    return Py_BuildValue("I", val);
}
static PyObject *
c_finish (PyObject *self, PyObject *args) {
  v_finish();

  Py_INCREF(Py_None);
  return Py_None;
}

// メソッドの定義
static PyMethodDef TopMethods[] = {
    {"cc_init",   (PyCFunction)cc_init,   METH_VARARGS, "top1: cc_init"},
    {"cc_random", (PyCFunction)cc_random, METH_VARARGS, "top2: cc_random"},
    {"c_init",    (PyCFunction)c_init,    METH_VARARGS, "top3: c_init"},
    {"c_random",  (PyCFunction)c_random,  METH_VARARGS, "top4: c_random"},
    {"c_finish",  (PyCFunction)c_finish,  METH_NOARGS,  "top5: c_finish"},
    // 終了を示す
    {NULL, NULL, 0, NULL}
};

//モジュールの定義
static struct PyModuleDef topmodule = {
    PyModuleDef_HEAD_INIT, "top", NULL, -1, TopMethods,
    NULL, NULL, NULL, NULL
};

// メソッドの初期化
PyMODINIT_FUNC PyInit_top (void) {
  return PyModule_Create(&topmodule);
}

DPI_LINK_DECL
int c_top() {
  PyObject *pName, *pModule, *pFunc;
  PyObject *pArgs;

  PyImport_AppendInittab("top", &PyInit_top);

  Py_Initialize();
  pName = PyUnicode_DecodeFSDefault("tb");
  /* Error checking of pName left out */

  pModule = PyImport_Import(pName);
  Py_DECREF(pName);

  if (pModule != NULL) {
    pFunc = PyObject_GetAttrString(pModule, "py_tb");
    /* pFunc is a new reference */

    if (pFunc && PyCallable_Check(pFunc)) {
      pArgs = PyTuple_New(0);
      PyObject_CallObject(pFunc, pArgs);
      Py_DECREF(pArgs);
    }
    else {
      if (PyErr_Occurred())
        PyErr_Print();
      fprintf(stderr, "Cannot find function\n");
    }
    Py_XDECREF(pFunc);
    Py_DECREF(pModule);
  }
  else {
    PyErr_Print();
    fprintf(stderr, "Failed to load\n");
    return 1;
  }
  if (Py_FinalizeEx() < 0) {
    return 120;
  }

  return 0;
}
