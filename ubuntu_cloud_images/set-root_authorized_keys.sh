#!/bin/bash
#===========================================================================
# Ubuntu Cloud Imagesで提供している仮想環境にrootでログインするための
# 設定を行うスクリプト。
# ついでにディスクイメージサイズを40GBに拡張。
#
# 前提
#   - qemuとcloud-image-utilsをインストールしておくこと
#
# 使用方法
#   - てきとうなディレクトリーに本スクリプトファイルを保存
#     - 実行権限の付加もやっておく
#   - ディスクイメージ(*.img)と公開鍵ファイル(*.pub)も一緒に格納
#   - root権限でスクリプトを実行
#     $ sudo ./set-root_authorized_keys.sh
#   - 以上
#
# note
#   - イメージサイズは必要に応じて適宜変更。
#   - 最初のパーティションがroot(/)であると想定。将来のバージョンで変更された
#     場合は変更の必要あり。
#===========================================================================

mkdir /mnt/nbd
modprobe nbd
sleep 1

for imgfile in *.img
do
	echo $imgfile

	qemu-img resize $imgfile 40g
	qemu-nbd -c /dev/nbd0 $imgfile
	sleep 1
	mount /dev/nbd0p1 /mnt/nbd

	mkdir /mnt/nbd/root/.ssh
	for pubfile in *.pub
	do
		cat $pubfile >> /mnt/nbd/root/.ssh/authorized_keys
	done

	umount /mnt/nbd
	qemu-nbd -d /dev/nbd0
	sleep 1
done

modprobe -r nbd
sleep 1
rmdir /mnt/nbd
