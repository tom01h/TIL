# Python から Verilator を呼び出す

PYNQ の協調検証を立ち上げるための調査です。

[C言語でPythonのモジュール作ってみる](https://qiita.com/Kashiwara/items/2088ba011446637aa8f4) を参考にして、Verilator モジュールを作ります。

Python3 と Verilator は既にインストールされているものとして、


```
$ sudo apt install python3-pip
$ pip3 install setuptools
```

で、準備をします。

だいぶ強引ですが、 `setup.py` にverilog から変換されたファイルとVerilatorのライブラリからコピーしてきたファイルも羅列します。

リンク先では `from distutils.core` していますが今どきじゃないとのことで `from setuptools` に変更しています。

ライブラリのコンパイルは、VerilogからC++への変換後にPythonモジュールのコンパイルをします。

```
$ make
```

`Makefile` はかなりハードコードしちゃってますが、見た通りのコマンドを実行しています。

で、テストの実行は、

```
$ python3 test.py
```

波形が `tmp.vcd` に取得できました。