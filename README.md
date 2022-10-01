## ちょい借り

Yahoo主催のハッカソンであるHach U 2022で作成したアプリケーションです。
約1週間で作成を行い、20チームの中で優秀賞を受賞しました。

## アプリの概要
同じWi-Fiに繋がっている人同士で物の貸し借りをよりスムーズに行うためのモバイルアプリです。(Webでも可能ですが、Web版だとWi-fi機能がありません。)</br>
親しくない人や全く知らない人との物の貸し借りはハードルが高いという問題を解決するために、Wi-Fiによってコミュニティを制限し、評価機能を付けることで物の貸し借りのハードルを下げることを手助けするためのアプリです。

## 使い方(ローカル(Web版))
1. 自身でfirebaseプロジェクトを作成し、lib/firebase_options.dartに必要なapikeyなどを入力
2. flutter run -d chrome --web-renderer htmlでサーバを起動
3. メールアドレスと名前でSign Upを行うことで、他の人の投稿を確認 or 自分で借りたいものを投稿 

## 使用技術
Flutter, Firebase

## 作品プレゼン
[プレゼン資料.pptx](https://github.com/chest760/choigari_app/files/9690392/default.pptx)
