# 高速加算器

## Carry Lookahead Adder

桁上げ (キャリー) を入力から出力へ伝える条件の ***Propagator (p)*** と、キャリーの発生する条件の ***Generator (g)*** を用た時のキャリー出力は、

<div align="left"><img src="https://latex.codecogs.com/svg.latex?g = a\cdot b" /></div>
<div align="left"><img src="https://latex.codecogs.com/svg.latex?p = a\oplus b" /></div>
<div align="left"><img src="https://latex.codecogs.com/svg.latex?c_{out} = g + p\cdot c_{in}" /></div>


ちなみに、変形すると Full Adder の時と同じ。

<div align="left"><img src="https://latex.codecogs.com/svg.latex?\\
    = a\cdot b + (a\oplus b)\cdot c_{in} \\
    = a\cdot b + (\overline{a}\cdot b + a\cdot\overline{b})\cdot c_{in}\\
    = a\cdot b + \overline{a}\cdot b\cdot c_{in} + a\cdot\overline{b}\cdot c_{in} + a\cdot b\cdot c_{in}\\
    = a\cdot b + b\cdot c_{in} + a\cdot c_{in}
    "/></div>
### 4bit CLA の例

各4bitの入力A,Bの和をSとする。

<div align="left"><img src="https://latex.codecogs.com/svg.latex?S=A+B+c_{in}" /></div>
2入力の和は、各bitの入力もしくは Propagator とキャリーを使って以下のように計算できる。

<div align="left"><img src="https://latex.codecogs.com/svg.latex?\\
    s_0 = a_0\oplus b_0\oplus c_{in} = p_0\oplus c_{in} \\
   	s_1 = a_1\oplus b_1\oplus c_0 = p_1\oplus c_0 \\
    s_2 = a_2\oplus b_2\oplus c_1 = p_2\oplus c_1  \\
    s_3=a_3\oplus b_3\oplus c_2 = p_3\oplus c_2" /></div>

キャリーは Generator と Propagator を使って以下のように計算できる。

<div align="left"><img src="https://latex.codecogs.com/svg.latex?\\
    c_0 = g_0 + p_0\cdot c_{in} = g_0 + p_0\cdot c_{in} \\
    c_1 = g_1 + p_1\cdot c_0 = g_1 + p_1\cdot g_0 + p_1\cdot p_0 \cdot c_{in} \\
    c_2 = g_2 + p_2\cdot c_1 = g_2 + p_2\cdot g_1 + p_2\cdot p_1 \cdot g_0 + p_2\cdot p_1 \cdot p_0\cdot c_{in} \\
    c_3 = g_3 + p_3\cdot c_2 = g_3 + p_3\cdot g_2 + p_3\cdot p_2\cdot g_1 + p_3\cdot p_2\cdot p_1 \cdot g_0 + p_3\cdot p_2\cdot p_1 \cdot p_0\cdot c_{in}" /></div>

