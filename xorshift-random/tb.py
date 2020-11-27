import random
import math
import top as top

def py_tb():
    init = random.randrange(1<<64)
    top.cc_init(init)
    top.c_init(init)

    NG = 0
    for n in range(100, 200):
        msk = ( 1<<(math.ceil(math.log2(n-1))) ) -1
        c = top.cc_random(n%2, n, msk)
        v = top.c_random(n%2, n, msk)
        if c==v:
            print(n, v)
        else:
            print("NG:", n, v)    
            NG = 1

    if NG==0:
        print("PASS")
    else :
        print("NG")
    
    top.c_finish()

    return