# DPI-Python もどきを作る

DPI-C と [Python-API](https://docs.python.org/ja/3/extending/embedding.html) を使って Python から Verilog Task を呼びます。

テストは Python スクリプト `tb.py` から制御します。

Verilog Task は、初期化 `v_init` 、終了 `v_finish` 、と、`top` モジュールの AXI スレーブ IF と AXI Stream マスターとスレーブを制御する、レジスタライト `v_write` 、ストリーム入力 `v_send` 、ストリーム出力 `v_receive` があります。

テスト全体の流れは

- 初期化 `v_init`
- Python スクリプトで乱数で行列を作って `v_send`
- 以下を繰り返す (2回)
  - Python スクリプトで乱数で行列を作って `v_send`
  - Verilog で行列乗算を計算して結果を `v_receive`
  - Python スクリプトで期待値を計算して先の値と比較
- 終了 `v_finish`

### tb.py の起動方法2通り

#### Verilog から Python を呼ぶ場合は…

build.sh の top.cpp→tb.cpp に変更して、コンパイル時の Python をインクルードしてリンクするところのコメントを外す

build.sh と run.sh の最後の↓の部分を削除する

```
 > /dev/null &

python.exe tb.py
```

tb.cpp でエラー処理をちゃんとしないと tb.py にエラーがあっても解析し難いです。起動の流れは、

1. Verilog シミュレータ起動
2. tb.v 内の c_tb() 呼び出しで tb.cpp 内の c_tb() を実行
3. `PyUnicode_DecodeFSDefault("tb");` で tb.py を指定して
4.  `PyObject_GetAttrString(pModule, "py_tb");` で tb.py の py_tb を呼び出す
5. tb.py の top.c_XX で tb.cpp の c_XX を経由して tb.v の v_XX を呼び出しつつ Verilog シミュレーション実行

#### MMAP した tb.txt 経由でマルチプロセス

tb.py を python コマンドから呼ぶのでエラーメッセージがちゃんと出ます。起動の流れは、

1. Verilog シミュレータ起動
2. tb.v 内の c_tb() 呼び出しで top.cpp 内の c_tb() を実行
5. tb.py を python コマンドから起動
6. tb.py の top.c_XX が top.py から MMAP 経由で top.cpp を経由して tb.v の v_XX を呼び出しつつ Verilog シミュレーション実行

## 準備

Windows にインストールした ModelSim と Python 3.6 を WSL から使います。

- ModelSim をインストール
  
  - gcc は ModelSim 付属のものを使う (intelFPGA_pro/19.4/modelsim_ase/gcc-4.2.1-mingw32vc12/bin/ 的なやつ)
- [ここ](https://pythonlinks.python.jp/ja/index.html) からダウンロードした **32bit 版** Python をインストール
  
  - パスのトップにないとだめかもしれない
  
  - Windowsに追加するパス↓
  
  - ```
    C:\intelFPGA_pro\19.4\modelsim_ase\win32aloem
    C:\intelFPGA_pro\19.4\modelsim_ase\gcc-4.2.1-mingw32vc12\bin
    C:\Users\tom01\AppData\Local\Programs\Python\Python36-32
    C:\Users\tom01\AppData\Local\Programs\Python\Python36-32\Scripts
    ```

## 実行

コンパイル＆実行は `build.sh`

実行のみは `run.sh`

Python のパスと ModelSim のパスは修正が必要です。

