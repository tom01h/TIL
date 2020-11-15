import numpy as np
import random

import top

def py_tb():
    print("Hello Python!!")
    
    top.c_init()


    print("--- Set Matrix ---");
    matrix = np.zeros(shape=(4,8), dtype=np.uint32)

    for j in range(4):
        for i in range(8):
            matrix[j][i] = random.randrange(255)

    print(matrix)

    top.c_write(0, 1)
    top.c_send(matrix.flatten().tolist())
    top.c_write(0, 0)
    
    # run
    top.c_write(0, 2)

    in_data  = np.zeros(shape=(4,8), dtype=np.uint32)
    out_data = np.zeros(shape=(4,4), dtype=np.uint32)

    for n in range(2):
        print("--- Sample", n, "Input ---")
        for j in range(4):
            for i in range(8):
                in_data[j][i] = random.randrange(255)
        print(in_data)

        top.c_send(in_data.flatten().tolist())
        out_data = np.array(top.c_receive(16)).reshape((4,4))

        print("--- Sample", n, "Output ---")
        for j in range(4):
            sum=[0]*4
            for k in range(8):
                for i in range(4):
                    sum[i] += matrix[i][k] * in_data[j][k]

            print(out_data[j])
            for i in range(4):
                if out_data[j][i] != sum[i]:
                    print("(Error Expecetd =", i, sum[i], ") ")

    top.c_write(0, 0)
    del matrix, in_data, out_data

    top.c_finish()

    return