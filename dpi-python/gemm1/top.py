'''
  {"c_init",    (PyCFunction)c_init,    METH_NOARGS,  "top1: c_init"},
  {"c_finish",  (PyCFunction)c_finish,  METH_NOARGS,  "top2: c_finish"},
  {"c_write",   (PyCFunction)c_write,   METH_VARARGS, "top3: c_write"},
  {"c_send",    (PyCFunction)c_send,    METH_VARARGS, "top4: c_send"},
  {"c_receive", (PyCFunction)c_receive, METH_VARARGS, "top5: c_receive"},
'''

import mmap

def c_init():
    f = open("tb.txt", "r+b")
    global mm
    mm = mmap.mmap(f.fileno(), 0)
    mm[0:1] = b"\1"
    while mm[0:1] != b'\0':
        pass
    return

def c_finish():
    mm[0:1] = b"\2"
    while mm[0:1] != b'\0':
        pass
    return

def c_write(address, data):
    mm[8:16] = address.to_bytes(8, byteorder='little')
    mm[16:24] = data.to_bytes(8, byteorder='little')
    mm[0:1] = b"\3"
    while mm[0:1] != b'\0':
        pass
    return

def c_send(list):
    mm[8:16] = len(list).to_bytes(8, byteorder='little')
    for i in range(len(list)):
        mm[8*i+16:8*i+24] = list[i].to_bytes(8, byteorder='little')
    mm[0:1] = b"\4"
    while mm[0:1] != b'\0':
        pass
    return

def c_receive(num):
    list = [0] * num
    mm[8:16] = num.to_bytes(8, byteorder='little')
    mm[0:1] = b"\5"
    while mm[0:1] != b'\0':
        pass
    list = []
    for i in range(int.from_bytes(mm[8:16], byteorder='little')):
        list.append(int.from_bytes(mm[8*i+16:8*i+24], byteorder='little'))
    return list