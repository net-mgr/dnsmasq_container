# dnsmasqの設定ファイル
## dnsmasq
dnsmsq 公式サイト：https://thekelleys.org.uk/dnsmasq/doc.html


## 使い方
1. Dokcerイメージの作成
```
docker build . -t dnsmasq:1
```

2. Dockerボリュームの作成
```
docker volume create dnsmasq-volume
```
作成したボリュームは
`/var/lib/docker/volumes/`以下でアクセス可能

ローカルDNSで解決したいホストファイルを作成し，以下のように配置（ホストファイル:hosts-dnsmasq）

`/var/lib/docker/volumes/dnsmasq-volume/_data/hosts-dnsmasq`


3. Dockerコンテナの起動
```
docker run -p 5053:53/udp -v dnsmasq-volume:/mnt --name dnsmasq dnsmasq:1
```
`-p 5053:53/udp`…公開するポート番号を指定 (udp)

`-v dnsmasq-volume:/mnt`…dnsmasqのhostsファイルを含んだボリュームをマウント


4. 確認

以下のコマンドでDNSが起動しているか確認
```
nslookup -port=5053 dns localhost
```

5. DNSの更新

更新が必要な場合，
`/var/lib/docker/volumes/dnsmasq-volume/_data/hosts-dnsmasq`
を編集し，
```
docker restart dnsmasq
```
を実行
