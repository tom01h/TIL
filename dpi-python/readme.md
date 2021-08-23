# DPI-Python もどきを作る

DPI-C と [Python-API](https://docs.python.org/ja/3/extending/embedding.html) を使って Verilog から Python スクリプトを起動、Python から Verilog Task を呼びます。

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

