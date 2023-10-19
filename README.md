# HTLAB.NET DRSSTC SFP Transceiver Ver1.0

SFP通信可能なDRSSTC用トランシーバーです。  
BNCケーブルでのインタラプタ信号を光ファイバーに置き換える目的で使用します。  


## 特徴
- 4bitの信号を双方向伝送可能。
- 8b10bエンコードを採用しており信頼性の高い通信が可能。
- コードエラーや光信号低下によるリンク切断時には出力状態を Low or 前回値保持 に設定可能。
- BiDi SFP Module を使用することで、1芯の光ファイバで双方向通信が可能。

***

## 諸性能

| 項目 | 値 |
| ---- | ---- |
| MCO (Master Clock) | 60 MHz |
| SFP Serial Rate | 20 Mbps |
| RawPls Sampling Rate | 2 MS/s (0.5us) |
| 伝送可能bit数 | 4bit (RawPls 1bit, Option 3bit) |
| エラー検出機能 | 8b10bコードエラー、LOS信号検知、フレームパリティチェック |
| LED表示 | SFPエラー状態、リンク状態、D1状態を表示 |

## DIP設定内容

| DIPスイッチ | 番号 | 概要 |
|----|----|----|
| SW1 | 1 | D1エラー時出力状態<br> - ON:前回値保持<br> - OFF:強制Low |
| SW1 | 2 | D2エラー時出力状態 |
| SW1 | 3 | D3エラー時出力状態 |
| SW1 | 4 | D4エラー時出力状態 |
| SW1 | 5 - 8 | Reserved |
| SW2 | 1 | ON:Master<br>OFF:Slave |
| SW2 | 2 - 8 | Reserved |


## フレーム構造
8bitフレームの構造は以下の通り。送受信共通フォーマット。

| bit | Name  | 説明 |
|-----|----|----|
| 1 | START | スタートビット（1固定） |
| 2 | LOCK | 8b10bシンボルロック状態（1:ロック中、0:未ロック中） |
| 3 | D1 | RawData1 |
| 4 | D2 | RawData2 |
| 5 | D3 | RawData3 |
| 6 | D4 | RawData4 |
| 7 | M/S | 1:Master、0:Slave |
| 8 | P | フレームパリティ（奇数パリティ） |

## Status LED
SFPスロットの左側がTX表示、右側がRX表示

| LED | 説明 | 
|-----|-----| 
| TX(RED) | 消灯:電源OFF<br>点灯:正常<br>点滅:TXエラー |
| TX(GR) | 送信したD1に連動 |
| RX(RED) | 消灯:電源OFF<br>点灯:正常<br>点滅:RXエラー |
| RX(GR) | 受信したD1に連動 |

- TXエラー：TX_FLT（SFPモジュール送信機故障）, DEF0（SFPモジュール抜け）のいずれか
- RXエラー：LOS（受信信号レベル低下）、DEF0（SFPモジュール抜け）、8b10bアンロックのいずれか

## SFP規格
https://www.snia.org/technology-communities/sff/specifications

INF-8074を参照

## 開発環境
- Quartus Prime Version 20.1.1 Build 720 Lite Edition
- ModelSim INTEL FPGA STARTER EDITION 2020.1

## クレジット
 - @pcjpnet (http://htlab.net/)
 - @twi_kingyo (http://kingyonull.blogspot.com/)
