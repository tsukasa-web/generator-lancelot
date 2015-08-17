module.exports = (grunt) ->

	path = require 'path'
	pkg = grunt.file.readJSON 'package.json'

	# パスの設定
	pathConfig = 
		root: '<%= rootDirectory %>' #project root
		dest: '<%= buildDirectory %>' #build root
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
					'<%%= path.dest %>/<%%= path.src %>/css/style.css': '<%%= path.root %>/<%%= path.compile %>/scss/style.scss'

		### Image SpriteSheetの作成
		------------------------------------------------------------------------###
		sprite:
			all:
				src: '<%%= path.root %>/<%%= path.src %>/img/sprite/*.png'
				destCSS: '<%%= path.root %>/<%%= path.compile %>/scss/lib/_sprite.scss'
				destImg: '<%%= path.dest %>/<%%= path.src %>/img/sprite.png'
				padding: 2
				algorithm: 'binary-tree'
				imgPath: '<%%= path.dest %>/<%%= path.src %>/img/sprite.png'

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
					'<%%= path.dest %>/<%%= path.src %>/img/sprite.svg': [
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
					'<%%= path.dest %>/<%%= path.src %>/img/sprite.svg': '<%%= path.root %>/<%%= path.src %>/img/sprite.svg'

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
					dest: '<%%= path.dest %>'
					ext: '.html'
				}]

		### js,cssファイルの結合
		------------------------------------------------------------------------###
		concat:
			script:
				src: [
					'<%%= path.root %>/<%%= path.src %>/js/dest/lib.js'
				]
				dest: '<%%= path.dest %>/<%%= path.src %>/js/lib.js'

		### jsファイルの圧縮（ライセンス表記のコメントはコメント内容の先頭に@licenseを必ず表記してください！
		------------------------------------------------------------------------###
		uglify:
			options:
				preserveComments: "some"
			lib:
				src: ['<%%= path.dest %>/<%%= path.src %>/js/lib.js'],
				dest: '<%%= path.dest %>/<%%= path.src %>/js/lib.js'
			run:
				src: ['<%%= path.dest %>/<%%= path.src %>/js/run.js'],
				dest: '<%%= path.dest %>/<%%= path.src %>/js/run.js'

		### cssファイルの圧縮
		------------------------------------------------------------------------###
		cssmin:
			style:
				src: ['<%%= path.dest %>/<%%= path.src %>/css/style.css'],
				dest: '<%%= path.dest %>/<%%= path.src %>/css/style.css'

		### cssファイルの不要prefix消去
		------------------------------------------------------------------------###
		autoprefixer:
			options:
				# ブラウザのバージョン指定
				browsers: ['last 2 version']
			no_dest:
				src: '<%%= path.dest %>/<%%= path.src %>/css/style.css'

		### csslintによるcssチェック。結果はコンソールに表示
		------------------------------------------------------------------------###
		csslint:
			dist:
				src: ['<%%= path.dest %>/<%%= path.src %>/css/style.css']

		### jsHintによるjsデバッグ。結果はコンソールに表示
		------------------------------------------------------------------------###
		jshint:
		# 対象ファイルを指定
			all: ['<%%= path.dest %>/<%%= path.src %>/js/run.js']

		### styleguideの作成
		------------------------------------------------------------------------###
		kss:
			options:
				includeType: 'css'
				includePath: '<%%= path.dest %>/<%%= path.src %>/css/style.css'
				template: '<%%= path.root %>/<%%= path.documents %>/styleguide_temp'
			dist:
				files:
					'<%%= path.root %>/<%%= path.documents %>/modules': ['<%%= path.root %>/<%%= path.compile %>/scss/']

		### 変更保存の監視。指定階層のファイルの更新時にタスクを行う
		------------------------------------------------------------------------###
		esteWatch:
			options:
				dirs: [
					'<%%= path.root %>/**/',
					'<%%= path.root %>/<%%= path.src %>/img/sprite/**/'
				]
				livereload:
					enabled: true
					extensions: ['coffee', 'scss', 'jade', 'jpg', 'png', 'gif', 'frag', 'vert']
					port: 35729
			coffee: (filepath) ->
				return ['browserify:dist', 'concat:script']
			scss: (filepath) ->
				return ['sass', 'autoprefixer:no_dest']
			jade: (filepath) ->
				return ['newer:jade']
			'*': (filepath) ->
				if filepath.indexOf('coffee') == -1 && filepath.indexOf('scss') == -1 && filepath.indexOf('jade') == -1
					return ['newer:copy']

		### browserifyによるモジュール管理
		------------------------------------------------------------------------###
		browserify:
			dist:
				files:
					'<%%= path.dest %>/<%%= path.src %>/js/run.js': ['<%%= path.root %>/<%%= path.compile %>/coffee/run.coffee']
				options:
					transform: ['coffeeify', 'debowerify', 'jadeify']
					external: ['jquery', 'underscore']
					browserifyOptions:
						extensions: ['.coffee']
			lib:
				files:
					'<%%= path.dest %>/<%%= path.src %>/js/lib.js': ['<%%= path.root %>/<%%= path.compile %>/coffee/lib.coffee']
				options:
					transform: ['coffeeify', 'debowerify', 'jadeify']
					require: ['jquery', 'underscore']
					browserifyOptions:
						extensions: ['.coffee']

		### Modernizr
  	------------------------------------------------------------------------###
		modernizr:
			dist:
				devFile : 'remote'
				#Path to save out the built file.
				outputFile : '<%%= path.dest %>/<%%= path.src %>/js/modernizr-custom.js'
				uglify : true
				parseFiles : false
				matchCommunityTests : true
				extra:
					shiv: true
					printshiv: false
					load: true
					mq: false
					cssclasses: true
				extensibility:
					addtest: true
					prefixed: true
					teststyles: true
					testprops: true
					testallprops: true
					hasevents: true
					prefixes: true
					domprefixes: true
				tests: ['video','webgl','webgl_extensions','touch','inlinesvg','cssanimations','csstransitions']

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
						return [folderMount(connect, '<%%= path.dest %>')] #ここでルートにしたいフォルダを指定

		### データ複製
		------------------------------------------------------------------------###
		copy:
			setup:
				files: [
					{
						expand: true
						cwd: 'bower_components/normalize-css'
						src: ['normalize.css']
						dest: '<%= rootDirectory %>/<%%= path.compile %>/scss/lib'
						rename: (dest, src) ->
							return dest + '/_normalize.scss'
					}
					{expand: true, cwd: 'bower_components/font-awesome/fonts', src: ['**'], dest: '<%= rootDirectory %>/<%%= path.src %>/fonts'},
					{expand: true, cwd: 'bower_components/font-awesome/scss', src: ['**'], dest: '<%= rootDirectory %>/<%%= path.compile %>/scss/font-awesome'}
				]
			media:
				expand: true
				cwd: '<%%= path.root %>'
				src: [
					'icons/**/*.{png,jpg,jpeg,gif,svg,svgz,xml,json,ico}'
					'media/**/*.{png,jpg,jpeg,gif,svg,svgz,mp4,m4v,webm,ogg,ogm}'
				]
				dest: '<%%= path.dest %>'
			common:
				expand: true
				cwd: '<%%= path.root %>/<%%= path.src %>'
				src: [
					'fonts/**/*'
					'img/**/*.{png,jpg,jpeg,gif,svg,svgz,mp4,m4v,webm,ogg,ogm}'
					'!img/sprite/**/*'
				]
				dest: '<%%= path.dest %>/<%%= path.src %>'
			parallelize:
				copy:
					media: 4
					common: 4
					parallelize: 4

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
			build:
				options:
					force: true # 強制的に上位ディレクトリを削除
				src: [
					'_build'
				]

	# gruntコマンドを打つと走るタスクです。
	grunt.registerTask 'default', ['clean:build','sass','jade','browserify:lib','modernizr','browserify:dist','autoprefixer','concat','copy:media','copy:common','connect','esteWatch']
	# grunt releaseコマンドを打つと走るタスクです。
	grunt.registerTask 'release', ['clean:build','sass','jade','browserify:lib','modernizr','browserify:dist','autoprefixer','concat','uglify','cssmin','copy:common','copy:icons']
	# grunt cssコマンドを打つと走るタスクです。browserifyによってlib.jsを出力します。
	grunt.registerTask 'makelib',['browserify:lib','modernizr']
	# grunt spriteコマンドを打つと走るタスクです。スプライト画像とスタイルを出力します。
	grunt.registerTask 'spriteImage', ['sprite:all','sass']
	# grunt spriteコマンドを打つと走るタスクです。スプライトSVGとスタイルを出力し、SVGを圧縮します。
	grunt.registerTask 'spriteSVG', ['svgstore','svgmin','jade']
	# grunt startコマンドを打つと走るタスクです。初期構築を行います。
	grunt.registerTask 'start', ['copy:setup','rename','clean:prepare']
	# grunt watch_filesコマンドを打つと走るタスクです。ファイルの監視・livereloadを行います。
	grunt.registerTask 'watch_files', ['connect','esteWatch']
	# grunt checkコマンドを打つと走るタスクです。css/jsをチェックします。
	grunt.registerTask 'check', ['csslint','jshint']
	# grunt styleコマンドを打つと走るタスクです。styleguideを作成します。
	grunt.registerTask 'style', ['kss']

	# jit-gruntを使用したプラグイン読み込み
	require('jit-grunt')(grunt)