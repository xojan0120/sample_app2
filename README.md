# 概要

Railsチュートリアルの機能拡張版。
拡張した機能は下記に記載。
https://github.com/xojan0120/sample_app2/issues?q=is%3Aissue+is%3Aclosed
各機能の設計は[Wiki](https://github.com/xojan0120/sample_app2/wiki)で確認できます。

ある程度改修が進んだ時点でmasterブランチへpushしています。
開発作業用のブランチ名には"feature/"が頭についています。

---
以下、RailsチュートリアルのデフォルトのREADMEです。

# Ruby on Rails チュートリアルのサンプルアプリケーション

これは、次の教材で作られたサンプルアプリケーションです。   
[*Ruby on Rails チュートリアル*](https://railstutorial.jp/)
[Michael Hartl](http://www.michaelhartl.com/) 著

## ライセンス

[Ruby on Rails チュートリアル](https://railstutorial.jp/)内にある
ソースコードはMITライセンスとBeerwareライセンスのもとで公開されています。
詳細は [LICENSE.md](LICENSE.md) をご覧ください。

## 使い方

このアプリケーションを動かす場合は、まずはリポジトリを手元にクローンしてください。
その後、次のコマンドで必要になる RubyGems をインストールします。

```
$ bundle install --without production
```

その後、データベースへのマイグレーションを実行します。

```
$ rails db:migrate
```

最後に、テストを実行してうまく動いているかどうか確認してください。

```
$ rails test
```

テストが無事に通ったら、Railsサーバーを立ち上げる準備が整っているはずです。

```
$ rails server
```

詳しくは、[*Ruby on Rails チュートリアル*](https://railstutorial.jp/)
を参考にしてください。
