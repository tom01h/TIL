# Petalinux と DMA を使うサンプル実装

Zynq 上で Petalinux と DMA を使うサンプル実装です。  
3回に分けて DMA を使えるようになる予定。

1回目: Petalinux のブート

2回目: PL 上の BRAM に uioを使ってアクセスする

3回目: PL 上の BRAM に DMA を使ってアクセスする



Petalinux の使い方は [ZYBO (Zynq) 初心者ガイド](https://qiita.com/iwatake2222/items/966f252f6ca954aff08b) がとってもわかりやすいので、そのまま真似をします。  
1回目は上記の 8回目と9回目の一部をなぞるだけです。2回目は16回目のチョイ変です。  
3回目に [udmabuf](https://github.com/ikwzm/udmabuf/blob/master/Readme.ja.md) を使って DMA 転送します。  
その先、GEMM アクセラレータ(整数版)に進むかどうかは気分次第です。  
ただ、tiny-dnn アクセラレータのレベルまで到達することはありません。

基本的には [Arty Z7(20)](http://akizukidenshi.com/catalog/g/gM-11921/) で進めて行きますが、たまに [CORA Z7(07S)](http://akizukidenshi.com/catalog/g/gM-13489/) とか Ultra96 のサンプルも作る予定。  
PL 部はすべて Verilog で書くので HLS も SDSoC も使いません。

### ツールバージョン

Vivado 2018.2

Petalinux 2018.2

