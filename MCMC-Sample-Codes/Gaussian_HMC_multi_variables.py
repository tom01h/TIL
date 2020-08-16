niter=10000
ntau=20
dtau=0.5
ndim=3     #number of variables

import numpy as np
import random
import math
import matplotlib.pyplot as plt

def graph(arr_x, arr_y, label_x, label_y, file_name):
    fig = plt.figure()
    ax = fig.add_subplot(111)
    plt.scatter(arr_x, arr_y, marker='+')
    plt.xlabel(label_x)
    plt.ylabel(label_y)
    plt.axis([-8, 8, -8, 8])
    ax.set_aspect('equal', adjustable='box')
    plt.savefig(file_name)
    plt.clf()


def calc_action(x, A):
    return 0.5 * np.dot(np.dot(x, A), x)


def calc_hamiltonian(x, p, A):
    return calc_action(x, A) + 0.5 * np.dot(p, p)


def calc_delh(x, A):
    return np.dot(A, x)


def Molecular_Dynamics(x, A):
    p = np.array([random.gauss(0, 1) for i in range(ndim)])
    #*** calculate Hamiltonian ***
    ham_init = calc_hamiltonian(x, p, A)
    #*** first step of leap frog ***
    x += 0.5 * dtau * p
    #*** 2nd, ..., Ntau-th steps ***
    for step in range(1, ntau):
        delh = calc_delh(x, A)
        p -= dtau * delh
        x += dtau * p
    #*** last step of leap frog ***
    delh = calc_delh(x, A)
    p -= dtau * delh
    x += 0.5 * dtau * p
    #*** calculate Hamiltonian again ***
    ham_fin = calc_hamiltonian(x, p, A)

    return ham_init, ham_fin


A = np.array([  [1.0, 1.0, 1.0],
                [1.0, 2.0, 1.0],
                [1.0, 1.0, 2.0]])

random.seed()

x = np.zeros(ndim)

naccept=0
arr = np.array([0,0,0,0])

for iter in range(niter):
    backup_x = x

    ham_init, ham_fin = Molecular_Dynamics(x, A)

    metropolis = random.random()
    if math.exp(ham_init - ham_fin) > metropolis:
        naccept += 1
    else:
        x = backup_x

    if iter % 10 == 0:
        l = np.append(x, naccept / (iter+1))
        arr = np.vstack((arr, l))

arr = np.delete(arr, 0, 0)
print(arr)

graph(arr[:, 0:1], arr[:, 1:2], 'x', 'y', 'xy.png')
graph(arr[:, 0:1], arr[:, 2:3], 'x', 'z', 'xz.png')
graph(arr[:, 1:2], arr[:, 2:3], 'y', 'z', 'yz.png')
