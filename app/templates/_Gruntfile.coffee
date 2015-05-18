module.exports = (grunt) ->

	path = require 'path'
	pkg = grunt.file.readJSON 'package.json'

	# パスの設定
	pathConfig = 
		root: '<%= rootDirectory %>' #project root
		src: '<%= common %>' #共通リソースの配置先
		compile: '<%= common %>/<%= compile %>' #コンパイル言語ソース類の配置先
		documents: '<%= _documents %>'
	folderMount = (connect, dir) ->
		return connect.static path.resolve(dir)

	grunt.initConfig

		### パス設定のロード
		------------------------------------------------------------------------###
		path: pathConfig

		### Scssのコンパイル
		------------------------------------------------------------------------###
		sass:
			options:
				includePaths: require('node-bourbon').includePaths
			dist:
				files:
					'<%%= path.root %>/<%%= path.src %>/css/dest/style.css': '<%%= path.root %>/<%%= path.compile %>/scss/style.scss'

		### Image SpriteSheetの作成
		------------------------------------------------------------------------###
		sprite:
			all:
				src: '<%%= path.root %>/<%%= path.src %>/img/sprite/*.png'
				destCSS: '<%%= path.root %>/<%%= path.compile %>/scss/lib/_sprite.scss'
				destImg: '<%%= path.root %>/<%%= path.src %>/img/sprite.png'
				padding: 2
				algorithm: 'binary-tree'
				imgPath: '/<%%= path.src %>/img/sprite.png'

		### SVG SpriteSheetの作成
  	------------------------------------------------------------------------###
		svgstore:
			options:
				prefix: 'sprite-'
				svg:
					version: '1.1'
					display: 'none'
				symbol: {}
				formatting: false
				includedemo: false
				cleanup: false
				cleanupdefs: false
				inheritviewbox: true
				fixedSizeVersion: false
				includeTitleElement: false
				preserveDescElement: false
			dev:
				files:
					'<%%= path.root %>/<%%= path.src %>/img/sprite.svg': [
						'<%%= path.root %>/<%%= path.src %>/img/sprite/*.svg',
						'!<%%= path.root %>/<%%= path.src %>/img/sprite/_*.svg'
					]

		### SVGの圧縮
  	------------------------------------------------------------------------###
		svgmin:
			options:
				plugins: [
					removeViewBox: false
				,
					removeUselessStrokeAndFill: false
				,
					cleanupIDs: false
				,
					removeHiddenElems: false
				]
			dev:
				files:
					'<%%= path.root %>/<%%= path.src %>/img/sprite.svg': '<%%= path.root %>/<%%= path.src %>/img/sprite.svg'

		### Jadeのコンパイル
		------------------------------------------------------------------------###
		jade:
			compile:
				options:
					debug: true
					pretty: true
				files: [{
					expand: true
					cwd: '<%%= path.root %>/<%%= path.compile %>/jade/'
					src: ['**/*.jade', '!_parts/*.jade', '!_templates/*.jade']
					dest: '<%%= path.root %>'
					ext: '.html'
				}]

		### js,cssファイルの結合
		------------------------------------------------------------------------###
		concat:
			script:
				src: [
					'<%%= path.root %>/<%%= path.src %>/js/dest/lib.js',
					'<%%= path.root %>/<%%= path.src %>/js/dest/run.js'
				]
				dest: '<%%= path.root %>/<%%= path.src %>/js/all.js'
			style:
				src: [
					'<%%= path.root %>/<%%= path.src %>/lib/normalize.css',
					'<%%= path.root %>/<%%= path.src %>/css/dest/style.css'
				]
				dest: '<%%= path.root %>/<%%= path.src %>/css/style-all.css'

		### jsファイルの圧縮（ライセンス表記のコメントはコメント内容の先頭に@licenseを必ず表記してください！
		------------------------------------------------------------------------###
		uglify:
			options:
				preserveComments: "some"
			run:
				src: ['<%%= path.root %>/<%%= path.src %>/js/all.js'],
				dest: '<%%= path.root %>/<%%= path.src %>/js/all.min.js'

		### cssファイルの圧縮
		------------------------------------------------------------------------###
		cssmin:
			style:
				src: ['<%%= path.root %>/<%%= path.src %>/css/style-all.css'],
				dest: '<%%= path.root %>/<%%= path.src %>/css/style-all.min.css'

		### cssファイルの不要prefix消去
		------------------------------------------------------------------------###
		autoprefixer:
			options:
				# ブラウザのバージョン指定
				browsers: ['last 2 version']
			no_dest:
				src: '<%%= path.root %>/<%%= path.src %>/css/dest/*.css'

		### csscssによるcssチェック。結果はコンソールに表示
		------------------------------------------------------------------------###
		csscss:
			options:
				compass: true
				ignoreSassMixins: true
			dist:
				src: ['<%%= path.root %>/<%%= path.src %>/css/dest/*.css']

		### csslintによるcssチェック。結果はコンソールに表示
		------------------------------------------------------------------------###
		csslint:
			dist:
				src: ['<%%= path.root %>/<%%= path.src %>/css/dest/*.css']

		### jsHintによるjsデバッグ。結果はコンソールに表示
		------------------------------------------------------------------------###
		jshint:
		# 対象ファイルを指定
			all: ['<%%= path.root %>/<%%= path.src %>/js/dest/*.js']

		### styleguideの作成
		------------------------------------------------------------------------###
		kss:
			options:
				includeType: 'css'
				includePath: '<%%= path.root %>/<%%= path.src %>/css/style-all.min.css'
				template: '<%%= path.root %>/<%%= path.documents %>/styleguide_temp'
			dist:
				files:
					'<%%= path.root %>/<%%= path.documents %>/modules': ['<%%= path.root %>/<%%= path.compile %>/scss/']

		### 変更保存の監視。指定階層のファイルの更新時にタスクを行う
		------------------------------------------------------------------------###
		esteWatch:
			options:
				dirs: [
					'<%%= path.root %>/<%%= path.compile %>/scss/**/',
					'<%%= path.root %>/<%%= path.compile %>/coffee/**/',
					'<%%= path.root %>/<%%= path.compile %>/ts/**/',
					'<%%= path.root %>/<%%= path.compile %>/jade/**/'
				]
				livereload:
					enabled: true
					extensions: ['coffee', 'scss', 'jade', 'jpg', 'png', 'gif', 'frag', 'vert']
					port: 35729
			coffee: (filepath) ->
				return ['browserify:dist', 'concat:script', 'uglify']
			scss: (filepath) ->
				return ['sass', 'autoprefixer:no_dest', 'concat:style', 'cssmin']
			jade: (filepath) ->
				return ['jade']

		### browserifyによるモジュール管理
		------------------------------------------------------------------------###
		browserify:
			dist:
				files:
					'<%%= path.root %>/<%%= path.src %>/js/dest/run.js': ['<%%= path.root %>/<%%= path.compile %>/coffee/run.coffee']
				options:
					transform: ['coffeeify', 'debowerify', 'jadeify']
					external: ['jquery', 'underscore']
					browserifyOptions:
						extensions: ['.coffee']
			lib:
				files:
					'<%%= path.root %>/<%%= path.src %>/js/dest/lib.js': ['<%%= path.root %>/<%%= path.compile %>/coffee/lib.coffee']
				options:
					transform: ['coffeeify', 'debowerify', 'jadeify']
					require: ['jquery', 'underscore']
					browserifyOptions:
						extensions: ['.coffee']

		### Jasmine
		------------------------------------------------------------------------###
		jasmine:
		# プロパティ名はテストケース名
			sample:
			# このテストケースでテストするファイルの指定
				src: 'src/js/sample.js'
				options:
				# テストケース
					specs: 'spec/*Spec.js'
				# ヘルパー
					helpers: 'spec/*Helper.js'

		### ローカルサーバー
		------------------------------------------------------------------------###
		connect:
			server:
				options:
					base: '.'
					livereload: true
					open: 'http://0.0.0.0:8000/'
					hostname: '0.0.0.0'
					port: 8000
					middleware: (connect, options) ->
						return [folderMount(connect, 'docs')] #ここでルートにしたいフォルダを指定

		### データ複製
		------------------------------------------------------------------------###
		copy:
			setup:
				files: [
					{expand: true, cwd: 'bower_components/modernizr', src: ['modernizr.js'], dest: '<%= rootDirectory %>/<%%= path.src %>/lib'},
					{expand: true, cwd: 'bower_components/normalize-css', src: ['normalize.css'], dest: '<%= rootDirectory %>/<%%= path.src %>/lib'},
					{expand: true, cwd: 'bower_components/font-awesome/fonts', src: ['**'], dest: '<%= rootDirectory %>/<%%= path.src %>/fonts'},
					{expand: true, cwd: 'bower_components/font-awesome/scss', src: ['**'], dest: '<%= rootDirectory %>/<%%= path.compile %>/scss/font-awesome'}
				]

		### ファイルリネーム
		------------------------------------------------------------------------###
		rename:
			setup:
				files: [
					{src: ['<%= rootDirectory %>/<%%= path.compile %>/scss/font-awesome/font-awesome.scss'], dest: '<%= rootDirectory %>/<%%= path.compile %>/scss/font-awesome/_font-awesome.scss'}
				]

		### 不要初期ファイル削除
		------------------------------------------------------------------------###
		clean:
			prepare:
				options:
					force: true # 強制的に上位ディレクトリを削除
				src: [
					'assets',
					'node_modules/generator-giraffe',
					'bower_components/modernizr',
					'bower_components/normalize-css',
					'bower_components/font-awesome',
					'.bowerrc',
					'.editorconfig',
					'.jshintrc',
					'.yo-rc.json',
					'bower.json'
				]

		### タスクの並列処理
		------------------------------------------------------------------------###
		parallelize:
			typescript:
				base: 4
			coffee:
				compile: 4
				compileAll: 4
			compass:
				dist: 4
			sprite:
				all: 4

	# gruntコマンドを打つと走るタスクです。
	grunt.registerTask 'default', ['sass','jade','csscss','browserify:lib','browserify:dist','autoprefixer','concat','uglify','cssmin']
	# grunt cssコマンドを打つと走るタスクです。browserifyによってlib.jsを出力します。
	grunt.registerTask 'makelib',['browserify:lib']
	# grunt cssコマンドを打つと走るタスクです。csscssによってスタイルの重複を出力します。
	grunt.registerTask 'csscss', ['csscss']
	# grunt spriteコマンドを打つと走るタスクです。スプライト画像とスタイルを出力します。
	grunt.registerTask 'spriteImage', ['sprite:all','sass']
	# grunt spriteコマンドを打つと走るタスクです。スプライトSVGとスタイルを出力し、SVGを圧縮します。
	grunt.registerTask 'spriteSVG', ['svgstore','svgmin','jade']
	# grunt startコマンドを打つと走るタスクです。初期構築を行います。
	grunt.registerTask 'start', ['copy','rename','clean:prepare']
	# grunt watch_filesコマンドを打つと走るタスクです。ファイルの監視・livereloadを行います。
	grunt.registerTask 'watch_files', ['connect','esteWatch']
	# grunt lintコマンドを打つと走るタスクです。css/jsにlint/hintを走らせます。
	grunt.registerTask 'lint', ['csslint','jshint']
	# grunt checkコマンドを打つと走るタスクです。css/jsをチェックします。
	grunt.registerTask 'check', ['csscss','csslint','jshint']
	# grunt styleコマンドを打つと走るタスクです。styleguideを作成します。
	grunt.registerTask 'style', ['kss']

	# jit-gruntを使用したプラグイン読み込み
	require('jit-grunt')(grunt)