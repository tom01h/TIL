# DPI-Python もどきを作る

dpi-python/ の Linux(Ubuntu) バージョン

## 準備

WSL2 インストールした ModelSim と Python 3.8 を使います。

### ModelSim をインストール

32bit ライブラリいろいろ入れた後に ModelSIM をインストールする

```
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install libxft2:i386
sudo apt install libxext6:i386
sudo apt install libstdc++6:i386
sudo apt install gcc-multilib g++-multilib
```


## 実行

コンパイル＆実行は `build.sh`

実行のみは `run.sh`

