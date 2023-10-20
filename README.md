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
| I/O Sampling Rate | 2 MS/s (0.5us) |
| 伝送可能bit数 | 4bit |
| エラー検出機能 | LOS信号検知、8b10bコードエラー、フレームパリティチェック |
| LED表示 | SFPエラー状態、リンク状態、D1状態を表示 |

## LED表示
SFPスロットの左側がTX表示、右側がRX表示

| LED | 説明 | 
|-----|-----| 
| TX(RED) | 消灯：電源OFF<br>点灯：正常<br>点滅：TXエラー |
| TX(GR) | 送信したD1に連動 |
| RX(RED) | 消灯：電源OFF<br>点灯：正常<br>点滅：RXエラー |
| RX(GR) | 受信したD1に連動 |

- TXエラー：TX_FLT（SFPモジュール送信機故障）, DEF0（SFPモジュール抜け）のいずれか
- RXエラー：LOS（受信信号レベル低下）、DEF0（SFPモジュール抜け）、8b10bアンロック、パリティエラーのいずれか

## DIP設定内容
| DIPスイッチ | 番号 | 概要 |
|----|----|----|
| SW1 | 1 | D1エラー時出力状態<br> - ON：前回値保持<br> - OFF：強制Low |
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
| 7:MSB | START | スタートビット（1固定） |
| 6 | LOCK | 8b10bシンボルロック状態（1：ロック中、0：未ロック中） |
| 5 | M/S | 1：Master、0：Slave |
| 4 | D4 | RawData4 |
| 3 | D3 | RawData3 |
| 2 | D2 | RawData2 |
| 1 | D1 | RawData1 |
| 0:LSB | P | フレームパリティ（奇数パリティ） |


## 端子信号割当
| ロケ | Pin No | I/O | 信号名 | 割当 | 備考 | 
|------|--------|-----|-------|------|-----|
| P1 | 1 | O | OUT1 | D1:RawData1(Rx) | 5V系 |
| P1 | 2 | PWR | GND | - | - |
| P2 | 1 | I | IN1 | D1:RawData1(Tx) | 5V系, 1kΩ Pull-Down |
| P2 | 2 | PWR | GND | - | - |
| P3 | 1 | PWR | 5V | 電源入力 | - |
| P3 | 2 | PWR | GND | - | - |
| P4 | 1 | PWR | 5V | - | - |
| P4 | 2 | PWR | GND | - | - |
| P4 | 3 | O | OUT2 | D2:RawData2(Rx) | 5V系 |
| P4 | 4 | I | IN2 | D2:RawData2(Tx) | 5V系, 1kΩ Pull-Down |
| P5 | 1 | PWR | 5V | - | - |
| P5 | 2 | PWR | 5V | - | - |
| P5 | 3 | PWR | 5V | - | - |
| P5 | 4 | PWR | 5V | - | - |
| P5 | 5 | PWR | GND | - | - |
| P5 | 6 | PWR | GND | - | - |
| P5 | 7 | PWR | GND | - | - |
| P5 | 8 | PWR | GND | - | - |
| P5 | 9 | O | OUT3 | D3:RawData3(Rx) | 5V系 |
| P5 | 10 | O | OUT4 | D4:RawData4(Rx) | 5V系 |
| P5 | 11 | O | OUT5 | LOCK(自機状態) | 5V系 |
| P5 | 12 | O | OUT6 | LOCK(受信フレーム状態) | 5V系, 自機が非LOCK状態の場合は最終受信状態を保持 |
| P5 | 13 | O | OUT7 | M/S | 5V系 |
| P5 | 14 | O | OUT8 | - | 5V系 |
| P5 | 15 | I | IN3 | D3:RawData3(Tx) | 5V系, 1kΩ Pull-Down |
| P5 | 16 | I | IN4 | D4:RawData4(Tx) | 5V系, 1kΩ Pull-Down |
| P5 | 17 | I | IN5 | - | 5V系, 1kΩ Pull-Down |
| P5 | 18 | I | IN6 | - | 5V系, 1kΩ Pull-Down |
| P5 | 19 | I | IN7 | - | 5V系, 1kΩ Pull-Down |
| P5 | 20 | I | IN8 | - | 5V系, 1kΩ Pull-Down |
| P6 | 1 | PWR | 3V3 | 電源出力 | - |
| P6 | 2 | PWR | 3V3 | 電源出力 | - |
| P6 | 3 | PWR | GND | - | - |
| P6 | 4 | PWR | GND | - | - |
| P6 | 5 | O | LV_OUT1 | D1:RawData1(Rx) | 3.3V系 |
| P6 | 6 | I | LV_IN1 | - | 3.3V系, Weak-Pull-Up |
| P6 | 7 | O | LV_OUT2 | D2:RawData2(Rx) | 3.3V系 |
| P6 | 8 | I | LV_IN2 | - | 3.3V系, Weak-Pull-Up |
| P6 | 9 | O | LV_OUT3 | D3:RawData3(Rx) | 3.3V系 |
| P6 | 10 | I | LV_IN3 | - | 3.3V系, Weak-Pull-Up |
| TP | 1 | O | TP1 | - | - |
| TP | 2 | O | TP2 | - | - |

- 割当が - となっているI/O端子は未使用
    - 出力端子：Low固定
    - 入力端子：FPGA内部では参照していない


## SFP規格
https://www.snia.org/technology-communities/sff/specifications

INF-8074を参照

## 開発環境
- Quartus Prime Version 20.1.1 Build 720 Lite Edition
- ModelSim INTEL FPGA STARTER EDITION 2020.1

## クレジット
 - @pcjpnet (http://htlab.net/)
 - @twi_kingyo (http://kingyonull.blogspot.com/)
