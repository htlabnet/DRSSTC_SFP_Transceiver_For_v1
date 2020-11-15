# HTLAB.NET DRSSTC SFP Transceiver Ver1.0

SFP通信可能なDRSSTC用トランシーバーです。

BNCケーブルでのインタラプタ信号を光ファイバーに置き換える目的で使用します。

***


## スイッチ設定内容

| DIPスイッチ | 番号 | 概要 |
----|----|----
| SW1 | 1 | トランスミッター有効 |
| SW1 | 2 | レシーバー有効 |
| SW1 | 3 | 10Mbps/20Mbps切替 |
| SW1 | 4 | ファイバー動作確認モード有効 |
| SW1 | 5 | 3.3V拡張有効 |
| SW1 | 6 | モード設定 |
| SW1 | 7 | モード設定 |
| SW1 | 8 | モード設定 |
| SW2 | 1 | 5V拡張(1)有効 |
| SW2 | 2 | モード設定 |
| SW2 | 3 | モード設定 |
| SW2 | 4 | モード設定 |
| SW2 | 5 | 5V拡張(2)有効 |
| SW2 | 6 | モード設定 |
| SW2 | 7 | モード設定 |
| SW2 | 8 | モード設定 |


## SFP規格
https://www.snia.org/technology-communities/sff/specifications

INF-8074を参照


## 開発環境
- Quartus II Version 13.1.0

## コーディング規約等
- .vのファイル名は、「モジュール名（小文字スネークケース）.v」とする
- topモジュールを除いて、入出力信号には方向を示す"i_" or "o_"を付ける
- インデントはスペース4とする


## クレジット
 - @pcjpnet (http://htlab.net/)
 - @twi_kingyo (http://kingyonull.blogspot.com/)
