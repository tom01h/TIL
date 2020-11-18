from setuptools import setup, Extension
import glob

filelist  = ['top.cpp', 'verilated.cpp', 'verilated_vcd_c.cpp']
filelist += glob.glob("sim/*.cpp")
setup(name='top',
        version='1.0',
        ext_modules=[Extension('top', filelist,extra_compile_args=['-DTRACE'])]
)
