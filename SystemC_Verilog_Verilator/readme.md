# SystemC + Verilog on Verilator

SystemC のシミュレーション実行環境を纏めておきます。  
SystemC と Verilog モジュールを、Verilator を使って一緒に検証できます。  
面倒ですが、受け渡し信号をテストベンチの eval() 関数内に列挙しなくてはなりません。  
行って来いのパスがあるとちゃんと動かないと思います。

また、HSL は驚くほどウェイトサイクルを挿入してくるので使用を断念しました。  
人力で Verilog に変換するのが、現状では現実的かと…

Verilator は C++ モードで実行しています。  
SystemC モードはシミュレーション速度がとっても遅くなったものですから。

## 実行法

まぁ、流してみるのが手っ取り早いかと…

```
$ make
$ ./sim/Vtop
```

波形は SystemC が sc.vcd、Verilog が tmp.vcd に出ます。  
2つを並べて見るのは面倒なので、SystemC モジュールの信号を無駄に Verilog モジュールに入力するのが良いと思っています。

## ファイルリスト

| モジュール   | ファイル             |
|--------------|----------------------|
| テストベンチ | test.cpp             |
| SystemC      | sc_top.h, sc_top.cpp |
| Verilog      | top.sv, loop_lib.sv  |

## 試したツールのバージョン

- g++ (Ubuntu 7.3.0-27ubuntu1~18.04) 7.3.0
- Verilator 4.010 2019-01-27 rev UNKNOWN_REV
- SystemC 2.3.3-Accellera

組み合わせが結構シビアなようです。

## お願い

Makefile がかなり格好悪いので、修正方法を募集しています。
