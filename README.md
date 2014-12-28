# generator-lancelot

A generator for [Yeoman](http://yeoman.io).  
高速化を念頭に置いて作成したIC用ジェネレータです。

## About giraffe

### 機能

* ディレクトリの初期構築
* CoffeeScriptのコンパイル
* Sassのコンパイル
* cssファイルの結合＆圧縮
* jsHintによるチェック
* cssLintによるチェック
* cssの重複プロパティチェック
* cssの不要プレフィックス削除
* este-watchによるファイル更新の監視→コンパイル・結合・圧縮・デバッグの自動化
* 自動ブラウザリロード
* jQueryの取得（バージョン指定可）
* mixinライブラリ（bourbon）を搭載
* 最新normalize/modernizr/font-awesomeの取得
* spritesmithによるsprite作成
* grunt-kssによるスタイルガイド生成
* 各種mixinなどのscssライブラリを追加
* Jadeに対応
* browserifyによるjsのモジュール管理と結合
* Jasmineによるテスト

### Install

使用する前に以下のツール群をインストールする必要があります。  
一部古いNode.jsに対応していないものもあるため、  バージョンが古い場合は、できるだけアップデートしておくことを推奨します。  
Windows環境では[Rubyのインストール](https://www.ruby-lang.org/ja/downloads/)、MacとWindow両方とも[Sass](http://sass-lang.com/install)/[Compass](http://compass-style.org/install/)のインストールが前提になります。

- [Node.js](http://nodejs.jp/)
- [Yeoman](http://yeoman.io/)
- [Grunt](http://gruntjs.com/)
- [Bower](http://bower.io/)
- [csscss](http://zmoazeni.github.io/csscss/)

```
$ npm install -g yo grunt-cli bower
$ gem install csscss
```

### How to use

generator-lancelotをインストールします。

	npm install -g generator-lancelot


任意のディレクトリを作成して移動し、```yo giraffe & grunt start```を実行します。  
環境によっては実行前に```git config --global url."https://".insteadOf git://```を実行する必要があります。

	mkdir hogehoge
	cd hogehoge
	yo lancelot && grunt start
	
yeomanからの質問形式で以下の設定を行います。

- 開発者名（packageのauthorに入ります）
- localhost（プロジェクト名）
- ルートディレクトリ名
- Jadeを使用するかどうか
- FontAwesomeを使用するかどうか
- 共通リソースディレクトリ名
- コンパイル言語ファイルの格納先
- ドキュメントディレクトリ名

質問に返答後、返答内容に応じたディレクトリが構成され、  
node_module等が自動的にインストールされます。

####js,cssファイルの結合

Gruntfile.jsを開き、結合したいcss,jsのパスを通します。  
上から順に結合されていくので、順番を間違えないようにしてください。  
ちなみにGrunt.jsにおいてルート相対・絶対パスは認識されません。   

    concat: {
    	style: {
    		src: [
    			'<%= path.root %>/<%= path.src %>/css/normalize.css',
    			'<%= path.root %>/<%= path.src %>/css/hogehoge.css'
    		],
    		dest: '<%= path.root %>/<%= path.src %>/css/dest/style-all.css'
    	}
    },


#### ファイル監視の起動

```grunt watch_files```コマンドでGrunt.jsで設定したlocalhost名でページが開き、ファイルの監視が始まります。
Sublime Text2でlivereloadのプラグインを入れてる人は、バッティングするのでプラグインをremoveしてから使ってください。  
この後、コンソールは出したままにしておいてください。最小化しても大丈夫です。  
以降はscss/coffee/js(Sassのみの時)が更新される度に自動的にコンパイル・結合・圧縮・デバッグが行われます。  
さらに、htmlとcss(sassを使っている人はscss更新時)の更新時に自動でブラウザがリロードされます。  
コンソールは消さずに出したままにしておいてください。監視をやめたい場合はコンソール上でCtrl+Cを押してください。　　
任意のタイミングでコンパイル・結合・圧縮・デバッグを行いたい場合は```grunt```コマンドを打ち込んでください。

#### livereloadのアドオン・エクステンションを取得

**Firefox**   
http://feedback.livereload.com/knowledgebase/articles/86242-how-do-i-install-and-use-the-browser-extensions-  
「Firefox extension」というやつです。  

**Chrome**  
https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei  


あとは追加されたアドオンのマークを押して、丸の中が赤くなれば成功です。  
ファイル監視を行っている最中に行ってください。  
後はhtmlまたはcss(sassの人はscss)を編集して保存した際にブラウザがリロードされればok。

#### styleguideの作成

```grunt styleguide```コマンドで作成が始まります。初期設定ではtemplate格納先はstyleguide_tempフォルダに、出力先はmodulesフォルダ内に設定されています。

- [grunt-kss](https://github.com/t32k/grunt-kss)

#### 重複プロパティのチェックとcss・jsのlint/hintチェック

```grunt check```を叩くと重複プロパティのチェックとcss/jsのlint/hintが始まります。初期設定では/common/css/destと/common/js/dest内にチェックの指定先が設定されています。lintの設定等はGruntfile.jsを書き換えて設定可能です。

- [grunt-contrib-csslint](https://github.com/gruntjs/grunt-contrib-csslint)
- [grunt-contrib-jshint](https://github.com/gruntjs/grunt-contrib-jshint)
- [grunt-csscss](https://github.com/peterkeating/grunt-csscss)

#### 不要プレフィックスのチェック

不要なプレフィックスを削除するためにautoprefixerを使用しています。ブラウザのバージョン指定はGruntfile.jsの下記部分になります。こちらのバージョンは変更可能です。下記リンクを参考にしてください。

	/* cssファイルの不要prefix消去
	 ------------------------------------------------------------------------*/
	autoprefixer: {
		options: {
			// ブラウザのバージョン指定
			browsers: ['last 2 version', 'ie 8']
		},
		no_dest: {
			src: '<%= path.root %>/<%= path.src %>/css/dest/*.css'
		}
	},

- [grunt-autoprefixer](https://github.com/nDmitry/grunt-autoprefixer)

#### スプライトシートの作成

Compassで毎回書き出すと遅くなるので、Compassのスプライトシート生成はgrunt-spritesmithで代用しています。```grunt sprite```を叩くとスプライトシートの生成が始まります。初期設定では/common/img/sprite内のpng画像が結合され、/common/img/にsprite.pngとして書き出されます。また、スタイルの設定ファイルは/common/compile/scss/lib/_sprite.scssに上書きされます。

## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License)