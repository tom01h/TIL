# 高速加算器

## Carry Lookahead Adder

桁上げ (キャリー) を入力から出力へ伝える条件の ***Propagator (p)*** と、キャリーの発生する条件の ***Generator (g)*** を用た時のキャリー出力は、

<!-- <div align="left"><img src="https://latex.codecogs.com/svg.latex?\\
    g = a\cdot b \\
    p = a\oplus b \\
    c_{out} = g + p\cdot c_{in}" /></div> <!-- --->

<div align="left"><img src="https://latex.codecogs.com/svg.latex?\\%20%20%20%20g%20=%20a\cdot%20b%20\\%20%20%20%20p%20=%20a\oplus%20b%20\\%20%20%20%20c_{out}%20=%20g%20+%20p\cdot%20c_{in}" /></div>

ちなみに、変形すると Full Adder の時と同じ。

<!-- <div align="left"><img src="https://latex.codecogs.com/svg.latex?\\
    = a\cdot b + (a\oplus b)\cdot c_{in} \\
    = a\cdot b + (\overline{a}\cdot b + a\cdot\overline{b})\cdot c_{in}\\
    = a\cdot b + \overline{a}\cdot b\cdot c_{in} + a\cdot\overline{b}\cdot c_{in} + a\cdot b\cdot c_{in}\\
    = a\cdot b + b\cdot c_{in} + a\cdot c_{in}
    "/></div>  <!-- --->

<div align="left"><img src="https://latex.codecogs.com/svg.latex?\\%20%20%20%20=%20a\cdot%20b%20+%20(a\oplus%20b)\cdot%20c_{in}%20\\%20%20%20%20=%20a\cdot%20b%20+%20(\overline{a}\cdot%20b%20+%20a\cdot\overline{b})\cdot%20c_{in}\\%20%20%20%20=%20a\cdot%20b%20+%20\overline{a}\cdot%20b\cdot%20c_{in}%20+%20a\cdot\overline{b}\cdot%20c_{in}%20+%20a\cdot%20b\cdot%20c_{in}\\%20%20%20%20=%20a\cdot%20b%20+%20b\cdot%20c_{in}%20+%20a\cdot%20c_{in}" /></div>

### 4bit CLA の例

各4bitの入力A,Bの和をSとする。

<div align="left"><img src="https://latex.codecogs.com/svg.latex?S%20=%20A+B+c_{in}" /></div>

2入力の和は、各bitの入力もしくは Propagator とキャリーを使って以下のように計算できる。

<!-- <div align="left"><img src="https://latex.codecogs.com/svg.latex?\\
    s_0 = a_0\oplus b_0\oplus c_{in} = p_0\oplus c_{in} \\
   	s_1 = a_1\oplus b_1\oplus c_0 = p_1\oplus c_0 \\
    s_2 = a_2\oplus b_2\oplus c_1 = p_2\oplus c_1  \\
    s_3 = a_3\oplus b_3\oplus c_2 = p_3\oplus c_2" /></div> <!-- --->

<div align="left"><img src="https://latex.codecogs.com/svg.latex?\\%20%20%20%20s_0%20=%20a_0\oplus%20b_0\oplus%20c_{in}%20=%20p_0\oplus%20c_{in}%20\\%20%20%20s_1%20=%20a_1\oplus%20b_1\oplus%20c_0%20=%20p_1\oplus%20c_0%20\\%20%20%20%20s_2%20=%20a_2\oplus%20b_2\oplus%20c_1%20=%20p_2\oplus%20c_1%20%20\\%20%20%20%20s_3=a_3\oplus%20b_3\oplus%20c_2%20=%20p_3\oplus%20c_2" /></div>

キャリーは Generator と Propagator を使って以下のように計算できる。

<!-- <div align="left"><img src="https://latex.codecogs.com/svg.latex?\\
    c_0 = g_0 + p_0\cdot c_{in} = g_0 + p_0\cdot c_{in} \\
    c_1 = g_1 + p_1\cdot c_0 = g_1 + p_1\cdot g_0 + p_1\cdot p_0 \cdot c_{in} \\
    c_2 = g_2 + p_2\cdot c_1 = g_2 + p_2\cdot g_1 + p_2\cdot p_1 \cdot g_0 + p_2\cdot p_1 \cdot p_0\cdot c_{in} \\
    c_3 = g_3 + p_3\cdot c_2 = g_3 + p_3\cdot g_2 + p_3\cdot p_2\cdot g_1 + p_3\cdot p_2\cdot p_1 \cdot g_0 + p_3\cdot p_2\cdot p_1 \cdot p_0\cdot c_{in}" /></div> <!-- --->

<div align="left"><img src="https://latex.codecogs.com/svg.latex?\\%20%20%20%20c_0%20=%20g_0%20+%20p_0\cdot%20c_{in}%20=%20g_0%20+%20p_0\cdot%20c_{in}%20\\%20%20%20%20c_1%20=%20g_1%20+%20p_1\cdot%20c_0%20=%20g_1%20+%20p_1\cdot%20g_0%20+%20p_1\cdot%20p_0%20\cdot%20c_{in}%20\\%20%20%20%20c_2%20=%20g_2%20+%20p_2\cdot%20c_1%20=%20g_2%20+%20p_2\cdot%20g_1%20+%20p_2\cdot%20p_1%20\cdot%20g_0%20+%20p_2\cdot%20p_1%20\cdot%20p_0\cdot%20c_{in}%20\\%20%20%20%20c_3%20=%20g_3%20+%20p_3\cdot%20c_2%20=%20g_3%20+%20p_3\cdot%20g_2%20+%20p_3\cdot%20p_2\cdot%20g_1%20+%20p_3\cdot%20p_2\cdot%20p_1%20\cdot%20g_0%20+%20p_3\cdot%20p_2\cdot%20p_1%20\cdot%20p_0\cdot%20c_{in}" /></div>

## Leading Zero Detection Adder

***Propagator (p)*** と ***Generator (g)*** に加え、キャリーを発生しない ***Eliminator (e)*** を用いる。

*p, g, e* はいずれか 1個だけが 1となるので、次のように置き換えて表現する。

例えば、

<!-- <div align="left"><img src="https://latex.codecogs.com/svg.latex?\\
    \begin{array}{rr} \\
		& 1010\\
	{+}	& 0011\\
    \hline
		& pegp\\
\end{array}" /></div> <!-- --->

<div align="left"><img src="https://latex.codecogs.com/svg.latex?\\%20%20%20%20\begin{array}{rr}%20\\&%201010\\{+}&%200011\\%20%20%20%20\hline&%20pegp\\\end{array}" /></div>

#### 正 + 正 の場合

<div align="left"><img src="https://latex.codecogs.com/svg.latex?e_i,\cdots,e_{j+1},\overline{e}_j,\cdots" /></div>

cj=1 の時 MSB は j+1 で、cj=0 の時 MSB は j である。

#### 負 + 負 の場合

<div align="left"><img src="https://latex.codecogs.com/svg.latex?g_i,\cdots,g_{j+1},\overline{g}_j,\cdots" /></div>

cj=0 の時 MSB は j+1 で、cj=1 の時 MSB は j である。

#### 正 + 負 = 正 の場合

<div align="left"><img src="https://latex.codecogs.com/svg.latex?p_i,\cdots,p_{j+2},g_{j+1},e_j,\cdots,e_{k+1},\overline{e}_k,\cdots" /></div>

ck=1 の時 MSB は k+1 で、ck=0 の時 MSB は k である。

#### 正 + 負 = 負 の場合

<div align="left"><img src="https://latex.codecogs.com/svg.latex?p_i,\cdots,p_{j+2},e_{j+1},g_j,\cdots,g_{k+1},\overline{g}_k,\cdots" /></div>

ck=0 の時 MSB は k+1 で、ck=1 の時 MSB は k である。

#### まとめると

<!-- <div align="left"><img src="https://latex.codecogs.com/svg.latex?\\
    \overline{p_{i+1}}\cdot((p_{i+2}\oplus g_{i+1}\oplus g_i) + (p_{i+2}\oplus e_{i+1}\oplus e_i)) = 1" /></div> <!-- --->

<div align="left"><img src="https://latex.codecogs.com/svg.latex?\\%20%20%20%20\overline{p_{i+1}}\cdot((p_{i+2}\oplus%20g_{i+1}\oplus%20g_i)%20+%20(p_{i+2}\oplus%20e_{i+1}\oplus%20e_i))%20=%201" /></div>

となる最大の *i* に対して、*sign^ci*=1 の時 MSB は i+1 で、*sign^ci*=0 の時 MSB は i である。

愚直な実装をすると [こう](https://github.com/tom01h/TIL/blob/1043fd14e0fae60c8c98bedfd7fb733981fa8219/adder/LeadingZeroDetectionAdder/lza.v) なると思いますが、正規化シフトの準備として使う場合は最後の +1 ビットのシフトは現物合わせのほうが効率よいと思います。