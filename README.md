# Smokeymonkey Amazon Prize Life Gallery

* すもけさんがみんなから受け取ったAmazonの救援物資を利用して自炊した画像を見れます
* AngularJS + Sinatra を利用してHerokuで公開しています

http://smokeymonkey-amazon-prize-life.herokuapp.com/

* Twitter の #朝飯、#昼飯、#晩飯のツイートを取得しています

# ツイートのデータ取得

* rubyのスクリプトを実行してjsonファイルを作成している都合で今は僕が手動で作成してアップロードする形になっているのでデータの反映にタイムラグが発せいします。

## Requirements

- AnguraJS v1.2.6
- Node.js v0.10.13
- Sinatra
- Ruby 2.0.0

## Configuration for Sinatra

### bundle install

    $ bundle install

### start server

    $ cd smokeymonkey-amazon-prize-life
    $ bundle exec rackup

### Visit

    http://0.0.0.0:9292/ with your favorite web browser.

## Configuration for node.js

### node install

    $ brew install node.js

### start server

    $ cd smokeymonkey-amazon-prize-life
    $ ./scripts/web-server.js

### Visit

    http://localhost:8000/app/index.html with your favorite web browser.

