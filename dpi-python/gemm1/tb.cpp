#include "svdpi.h"
#include "dpiheader.h"

#define PY_SSIZE_T_CLEAN
#include <Python.h>

static PyObject *
c_init (PyObject *self, PyObject *args) {
  v_init();

  Py_INCREF(Py_None);
  return Py_None;
}

static PyObject *
c_finish (PyObject *self, PyObject *args) {
  v_finish();

  Py_INCREF(Py_None);
  return Py_None;
}

static PyObject *
c_write (PyObject *self, PyObject *args) {
  int address, data;
  // 送られてきた値をパース
  if(!PyArg_ParseTuple(args, "ii",&address, &data))
    return NULL;

  v_write(address, data);

  Py_INCREF(Py_None);
  return Py_None;
}

static PyObject *
c_send (PyObject *self, PyObject *args) {
  int array[64];
  PyObject *p_list, *p_value;
  int size;
  long val;
  // 送られてきた値をパース
  if(!PyArg_ParseTuple(args, "O!", &PyList_Type, &p_list))
    return NULL;
  // リストのサイズ取得
  size = PyList_Size(p_list);

  for(int i = 0; i < size; i++){
    p_value = PyList_GetItem(p_list, i);
    array[i] = PyLong_AsLong(p_value);
  }

  v_send(array, size);

  Py_INCREF(Py_None);
  return Py_None;
}

static PyObject *
c_receive (PyObject *self, PyObject *args) {
  int array[64];
  int size;
  long val;
  PyObject *list;
  // 送られてきた値をパース
  if(!PyArg_ParseTuple(args, "i", &size))
    return NULL;

  list = PyList_New(0);

  v_receive(array, size);
  
  for(int i = 0; i < size; i++){
    val = array[i];
    PyList_Append(list, Py_BuildValue("i", val));
  }

  return list;
}

// メソッドの定義
static PyMethodDef topMethods[] = {
  {"c_init",    (PyCFunction)c_init,    METH_NOARGS,  "top1: c_init"},
  {"c_finish",  (PyCFunction)c_finish,  METH_NOARGS,  "top2: c_finish"},
  {"c_write",   (PyCFunction)c_write,   METH_VARARGS, "top3: c_write"},
  {"c_send",    (PyCFunction)c_send,    METH_VARARGS, "top4: c_send"},
  {"c_receive", (PyCFunction)c_receive, METH_VARARGS, "top5: c_receive"},
  // 終了を示す
  {NULL, NULL, 0, NULL}
};

//モジュールの定義
static struct PyModuleDef topmodule = {
  PyModuleDef_HEAD_INIT,  "top",  NULL,  -1,  topMethods,
  NULL, NULL, NULL, NULL
};

// メソッドの初期化
PyMODINIT_FUNC PyInit_top (void) {
  return PyModule_Create(&topmodule);
}

DPI_LINK_DECL
int c_tb() {
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
