# rpi-iroha-dev
IROHA Development container for Raspberry Pi3

```
docker build -t tkyonezu/rpi-iroha-dev .
```

| 時刻 | 時間 | swap |
|---|---|---|
| 02:08:00 | 05:21 | - | build 開始 |
| 02:13:31 | 58:20 | 8 | Debian アップグレード、追加ソフト導入 |
| 03:11:51 | 50:57 | 61946 | protobuf ビルド |
| 04:02:48 | 23:59 | 123608 | grpc ビルド |
| 04:26:47 | 02:36 | 122128 | build 最終 |
| 04:29:23 | - | - | build 終了 |

合計 2時間21分23秒

## Author
[Takeshi Yonezu](https://github.com/tkyonezu)
