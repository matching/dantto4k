# dantto4k

## このフォークは
このフォークは以下を目的としたものです。
- すでに復号されたMMTSを対象とすることで、ACASやスマートカードの処理を省き、RaspberryPIなど非x86_64のLinuxでもビルドできるようにする
- LinuxのEDCBで動作するBondriverのビルド（BonDriver_dantto4k.so）
- tsduckの依存関係が多すぎるので必要なソースだけスタティックビルド（AIを利用して対象ソースの選定をしています）

## 使用方法

### dantto4k
既に復号されているMMTSからMPEG-2 TSへの変換を行います。
```
Usage:
  dantto4k [OPTION...] input output ('-' for stdin/stdout)

      --listSmartCardReader     List available smart card readers（* このフォークでは無効）
      --casProxyServer arg      Specify the address of a CasProxyServer （* このフォークでは無効）
      --smartCardReaderName arg （* このフォークでは無効）
                                Specify the smart card reader to use
      --customWinscardDLL arg   Specify the path to a winscard.dll （* このフォークでは無効）
      --disableADTSConversion   Disable ADTS conversion
      --frontend-descrambled    Assume the input stream was already （* このフォークでは無条件にこのオプションが定義されたものとして扱う）
                                descrambled by the frontend, and only
                                remux MMT/TLV to MPEG-2 TS
      --no-progress             Disable progress display
      --no-stats                Disable packet statistics
      --help                    Show help
```

フロントエンド側で既に復号済みの MMTS を MPEG-2 TS に変換するだけの場合は、
`--frontend-descrambled` を指定します。このモードではスマートカードを初期化しません。

### BonDriver_dantto4k.dll
リアルタイムで復号化とMPEG-2 TSへの変換を行うBonDriverです。
BonDriver_dantto4k.iniで設定されたBonDriverをロードして、復号化とMPEG-2 TSへの変換を行います。
dantto4kは64bitで配布しており、BonRecTestおよびBonDriver_BDAは64bitである必要があります。

#### Mirakurunでの動作
PT4Kで動作する場合、チャンネル再生まで15～20秒かかるため、Mirakurunのtimeout(20秒)を超える場合があります。
Mirakurunのソースコードを修正してtimeoutを30秒以上に変更する必要があります。

https://github.com/Chinachu/Mirakurun/blob/master/src/Mirakurun/Tuner.ts

### CasProxyServer
スマートカードのプロキシサーバーが必要な場合、以下のリポジトリから構築できます。
https://github.com/nekohkr/casproxyserver

## ビルド
### Windows
/thirdpartyフォルダにtsduckとasio(v1.32.0)を準備します。
下記のURLからtsduckのbinaryをダウンロードすることができます。

- https://github.com/tsduck/tsduck/
### Ubuntu

```bash
git clone https://github.com/matching/dantto4k.git
cd dantto4k
git submodule update --init --recursive

make -j10
sudo cp ./build-linux/BonDriver_dantto4k.so /usr/local/lib/edcb
sudo cp ./ini/BonDriver_dantto4k.ini /usr/local/lib/edcb
# おそらく実害ないですが、"Error: configuration file 'dtv' not found" のエラー抑止
sudo cp ./build-linux/tsduck.dtv.names /usr/local/bin
```

### BonDriver_dantto4k.ini の bondriverPath の設定例
```
[bondriver]
bondriverPath=/usr/local/lib/edcb/BonDriver_LinuxMirakc.so
```

## References
- ARIB STD-B32
- ARIB STD-B60
- [superfashi/FFmpeg](https://github.com/superfashi/FFmpeg)
- b61decoder
