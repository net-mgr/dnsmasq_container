# dnsmasqの設定ファイル
## dnsmasq
dnsmsq 公式サイト：https://thekelleys.org.uk/dnsmasq/doc.html

## 使い方
### Dokcerイメージの作成
```shell
$ docker build . -t dnsmasq
```

### dnsmasq の管理
#### スクリプトを用いる方法
1. 起動
```shell
$ dnsmasq-docker.sh start
```
2. 起動 (バックグラウンドで動作させる場合)
```shell
$ dnsmasq-docker.sh start -d
```
3. 起動 (ポートを指定する場合)
```shell
$ dnsmasq-docker.sh start -p 53
```
4. 停止
```shell
$ dnsmasq-docker.sh stop
```
5. 再起動
```shell
$ dnsmasq-docker.sh restart -d -p 53
```
6. ステータス確認
```shell
$ dnsmasq-docker.sh status
```

より詳細な使い方については以下のコマンドを実行
```shell
$ dnsmasq-docker.sh help
```

#### systemd を用いる手法
+ 事前準備
    1. `systemd_conf/dnsmasq-docker.service` を `/etc/systemd/system` にコピー
    ```shell
    # cp systemd_conf/dnsmasq-docker.service /etc/systemd/system/
    ```
    2. コピーした `dnsmasq-docker.service` を書き換える
    ```shell
    # vim /etc/systemd/system/dnsmasq-docker.service
    ```
+ 管理
    + 起動
    ```shell
    # systemctl start dnsmasq-docker
    ```
    + 停止
    ```shell
    # systemctl stop dnsmasq-docker
    ```
    + ステータス確認
    ```shell
    # systemctl status dnsmasq-docker
    ```


### DNSの更新

更新が必要な場合，`conf/hosts`を編集し，再起動
```shell
$ dnsmasq-docker.sh restart
```
