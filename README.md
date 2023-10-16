# HTLAB.NET DRSSTC SFP Transceiver Ver1.0

SFP通信可能なDRSSTC用トランシーバーです。  
BNCケーブルでのインタラプタ信号を光ファイバーに置き換える目的で使用します。  


## 特徴
- 4bitの信号（1bitはインタラプタ用、残り3bitはオプション）を双方向伝送可能です。
- 8b10bエンコードを採用しており信頼性の高い通信が可能です。
- コードエラーや光信号低下によるリンク切断時には確実にインタラプト信号をLowに落とします。
- BiDi SFP Module を使用することで、1芯の光ファイバで双方向通信が可能です。

***

## 諸性能

| 項目 | 値 |
| ---- | ---- |
| MCO (Master Clock) | 60 MHz |
| SFP Serial Rate | 20 Mbps |
| RawPls Sampling Rate | 2 MS/s (0.5us) |
| 伝送可能bit数 | 4bit (RawPls 1bit, Option 3bit) |
| エラー検出機能 | 8b10bコードエラー、LOS信号検知、フレームパリティチェック |
| LED表示 | TX/RX RawPls、TX_FAULT、Link Status |

## スイッチ設定内容
**現在DIPスイッチによる設定変更は未実装です**  
**＜仕様案＞**  

| DIPスイッチ | 番号 | 概要 |
----|----|----
| SW1 | 1 | ON:Master Mode / OFF:Slave Mode |
| SW1 | 2 | Reserved |
| SW1 | 3 | Reserved |
| SW1 | 4 | Reserved |
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
- Quartus Prime Version 20.1.1 Build 720 Lite Edition
- ModelSim INTEL FPGA STARTER EDITION 2020.1

## クレジット
 - @pcjpnet (http://htlab.net/)
 - @twi_kingyo (http://kingyonull.blogspot.com/)
