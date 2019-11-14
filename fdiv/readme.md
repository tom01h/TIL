# ヘネパタ オンライン付録 J の除算器を FPU で実装する

ヘネパタ Computer Architecture 第6版 のオンライン付録の  J Computer Arithmetic で説明されている除算器を FPU で実装したいと思います。

1. J.9 の基数2の SRT 除算  $TOPFILE=fdiv2.sv
2. J.9 の基数4の SRT 除算  $TOPFILE=fdiv4.sv
   - Exercises J.33 b. の ”テーブルが P に対して正負対称であることを利用してテーブルを小さくしろ” に対応済み

#### 制限事項

特殊ケースのために資源を割くのはもったいないので、サブノーマル数の入出力には対応していません。  
サブノーマル数は0として扱う場合が多いけど、除数の場合は最小値のほうがよくないかと思っていたりします。  
ただし、この実装例ではどちらにも対応していません。

サブノーマル数に対応しない理由は、

1. 除数が正規化されていないと SRT が動かない
2. 被除数が正規化されていないと商も正規化されない ＆ 必要な精度を得るには追加のステップ数が必要
3. 答えをサブノーマルにするには仮数部の右シフトが必要
   - 丸め後に最小値に復活する場合も同様

#### シミュレーション

実行には Verilator と berkeley-testfloat が必要です。

```
$ make TOP={$TOPFILE}
$ {$PATH_TO_berkeley-testfloat-3}/build/Linux-x86_64-GCC/testfloat_gen -f32_div | ./sim/Vfdiv > log
```

