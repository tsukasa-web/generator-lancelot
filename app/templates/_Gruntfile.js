module.exports = function(grunt) {

	// ここに追加
	var pkg = grunt.file.readJSON('package.json');

	// パスの設定
	var pathConfig = {
		vh: '<%= localhost %>',		// バーチャルホストのサーバー名
		root: '<%= rootDirectory %>',				// project root
		src: '<%= common %>',				// 共通リソースの配置先
		compile: '<%= common %>/<%= compile %>',	// コンパイル言語ソース類の配置先
		dev: '../<%= _dev %>',
		documents: '<%= _documents %>'
	};

	grunt.initConfig({

		/* パス設定のロード
		 ---------------------------------------------------*/
		path: pathConfig,

		/* Scssのコンパイル
		 ------------------------------------------------------------------------*/
		sass: {
			options: {
				includePaths: require('node-bourbon').includePaths
			},
			dist: {
				files: {
					'<%%= path.root %>/<%%= path.src %>/css/dest/style.css':'<%%= path.root %>/<%%= path.compile %>/scss/style.scss'
				}
			}
		},
		//-----------------------------------------------------------------------

		/* SpriteSheetの作成
		 ------------------------------------------------------------------------*/
		sprite: {
			all:{
				src: '<%%= path.root %>/<%%= path.src %>/img/sprite/*.png',
				destCSS: '<%%= path.root %>/<%%= path.compile %>/scss/lib/_sprite.scss',
				destImg: '<%%= path.root %>/<%%= path.src %>/img/sprite.png',
				padding: 2,
				algorithm: 'binary-tree',
				imgPath: '/<%%= path.src %>/img/sprite.png'
			}
		},
		//-----------------------------------------------------------------------

		/* Jadeのコンパイル
		 ------------------------------------------------------------------------*/
		jade: {
			compile:{
				options:{
					debug: true,
					pretty: true,
					data: function(dest, src) {
						// --- Gruntfile内でオブジェクトを定義してtemplateに渡す時
						//return {
						//	from: src,
						//	to: dest
						//};

						// --- 外部ファイルからオブジェクトをtemplateに渡す時
						// return require('./locals.json');
					}

				},
				files:[{
					expand: true,
					cwd: '<%%= path.root %>/<%%= path.compile %>/jade/',
					src:['**/*.jade','!_parts/*.jade'],
					dest: '<%%= path.root %>',
					ext: '.html'
				}]
			}
		},
		//-----------------------------------------------------------------------

		/* js,cssファイルの結合
		 ------------------------------------------------------------------------*/
		concat: {
			style: {
				src: [
					'<%%= path.root %>/<%%= path.src %>/lib/normalize.css',
					'<%%= path.root %>/<%%= path.src %>/css/dest/style.css'
				],
				dest: '<%%= path.root %>/<%%= path.src %>/css/style-all.css'
			}
		},
		//-----------------------------------------------------------------------

		/* jsファイルの圧縮（ライセンス表記のコメントはコメント内容の先頭に@licenseを必ず表記してください！
		 ------------------------------------------------------------------------*/
		uglify: {
			options: {
				preserveComments: "some"
			},
			run: {
				src: ['<%%= path.root %>/<%%= path.src %>/js/dest/all.js'],
				dest: '<%%= path.root %>/<%%= path.src %>/js/all.min.js'
			}
		},
		//-----------------------------------------------------------------------

		/* cssファイルの圧縮
		 ------------------------------------------------------------------------*/
		cssmin: {
			style: {
				src: ['<%%= path.root %>/<%%= path.src %>/css/style-all.css'],
				dest: '<%%= path.root %>/<%%= path.src %>/css/style-all.min.css'
			}
		},
		//-----------------------------------------------------------------------

		/* cssファイルの不要prefix消去
		 ------------------------------------------------------------------------*/
		autoprefixer: {
			options: {
				// ブラウザのバージョン指定
				browsers: ['last 2 version', 'ie 9']
			},
			no_dest: {
				src: '<%%= path.root %>/<%%= path.src %>/css/dest/*.css'
			}
		},
		//-----------------------------------------------------------------------

		/* csscssによるcssチェック。結果はコンソールに表示
		 ------------------------------------------------------------------------*/
		csscss: {
			options: {
				compass: true,
				ignoreSassMixins: true
			},
			dist: {
				src: ['<%%= path.root %>/<%%= path.src %>/css/dest/*.css']
			}
		},
		//-----------------------------------------------------------------------

		/* csslintによるcssチェック。結果はコンソールに表示
		 ------------------------------------------------------------------------*/
		csslint: {
			dist: {
				src: ['<%%= path.root %>/<%%= path.src %>/css/dest/*.css']
			}
		},
		//-----------------------------------------------------------------------

		/* jsHintによるjsデバッグ。結果はコンソールに表示
		 ------------------------------------------------------------------------*/
		jshint: {
			// 対象ファイルを指定
			all: [
				'<%%= path.root %>/<%%= path.src %>/js/dest/*.js'
			]
		},
		//-----------------------------------------------------------------------

		/* styleguideの作成
		 ------------------------------------------------------------------------*/
		kss: {
			options: {
				includeType: 'css',
				includePath: '<%%= path.root %>/<%%= path.src %>/css/style-all.min.css',
				template: '<%%= path.root %>/<%%= path.documents %>/styleguide_temp'
			},
			dist: {
				files: {
					'<%%= path.root %>/<%%= path.documents %>/modules': ['<%%= path.root %>/<%%= path.compile %>/scss/']
				}
			}
		},
		//-----------------------------------------------------------------------

		/* 変更保存の監視。指定階層のファイルの更新時にタスクを行う
		 ------------------------------------------------------------------------*/
		esteWatch: {
			options: {
				dirs: [
					'<%%= path.root %>/<%%= path.compile %>/scss/**/',
					'<%%= path.root %>/<%%= path.compile %>/coffee/**/',
					'<%%= path.root %>/<%%= path.compile %>/ts/**/',
					'<%%= path.root %>/<%%= path.compile %>/jade/**/'
				],
				livereload: {
					enabled: false
				}
			},
			coffee: function(filepath) {
				return ['browserify','uglify'];
			},
			scss: function(filepath) {
				return ['sass','autoprefixer:no_dest','concat:style','cssmin'];
			},
			jade: function(filepath) {
				return ['jade'];
			}
		},
		//-----------------------------------------------------------------------

		/* browserifyによるモジュール管理
		 ------------------------------------------------------------------------*/
		browserify: {
			dist: {
				files: {
					'<%%= path.root %>/<%%= path.src %>/js/dest/all.js': ['<%%= path.root %>/<%%= path.compile %>/coffee/all.coffee']
				},
				options: {
					transform: ['coffeeify'],
					//external: ['jquery','underscore','hoge'],
					browserifyOptions: {
						extensions: ['.coffee']
					}
				}
			},
			lib: {
				files: {
					'<%%= path.root %>/<%%= path.src %>/js/dest/lib.js': ['<%%= path.root %>/<%%= path.compile %>/coffee/lib.coffee']
				},
				options: {
					transform: ['coffeeify', "debowerify"],
					//require: ['jquery','underscore','path/to/hoge.coffee:hoge'],
					browserifyOptions: {
						extensions: ['.coffee']
					}
				}
			}
		},
		//-----------------------------------------------------------------------

		/* Jasmine
		 ------------------------------------------------------------------------*/
		jasmine: {
			// プロパティ名はテストケース名
			sample: {
				// このテストケースでテストするファイルの指定
				src: 'src/js/sample.js',
				options: {
					// テストケース
					specs: 'spec/*Spec.js',
					// ヘルパー
					helpers: 'spec/*Helper.js'
				}
			}
		},
		//-----------------------------------------------------------------------

		/* livereload
		 ------------------------------------------------------------------------*/
		livereloadx: {
			dir: '<%%= path.root %>'
		},
		//-----------------------------------------------------------------------

		/* ページオープン
		 ------------------------------------------------------------------------*/
		// ページオープン用URL
		open: {
			dev: {
				path: 'http://<%%= path.vh %>/'
			}
		},
		//-----------------------------------------------------------------------

		/* データ複製
		 ---------------------------------------------------*/
		copy: {
			setup: {
				files: [
					{ expand: true, cwd: 'bower_components/modernizr', src: ['modernizr.js'], dest: '<%= rootDirectory %>/<%%= path.src %>/lib' },
					{ expand: true, cwd: 'bower_components/normalize-css', src: ['normalize.css'], dest: '<%= rootDirectory %>/<%%= path.src %>/lib' },
					{ expand: true, cwd: 'bower_components/font-awesome/fonts', src: ['**'], dest: '<%= rootDirectory %>/<%%= path.src %>/fonts' },
					{ expand: true, cwd: 'bower_components/font-awesome/scss', src: ['**'], dest: '<%= rootDirectory %>/<%%= path.compile %>/scss/font-awesome' }
				]
			}
		},
		//-----------------------------------------------------------------------

		/* ファイルリネーム
		 ---------------------------------------------------*/
		rename: {
			setup: {
				files: [
					{src: ['<%= rootDirectory %>/<%%= path.compile %>/scss/font-awesome/font-awesome.scss'], dest: '<%= rootDirectory %>/<%%= path.compile %>/scss/font-awesome/_font-awesome.scss'}
				]
			}
		},
		//-----------------------------------------------------------------------

		/* 不要初期ファイル削除
		 ---------------------------------------------------*/
		clean: {
			prepare: {
				options: {
					force: true // 強制的に上位ディレクトリを削除
				},
				src: [
					'assets',
					'node_modules/generator-giraffe',
					'bower_components',
					'.bowerrc',
					'.editorconfig',
					'.jshintrc',
					'.yo-rc.json',
					'bower.json'
				]
			}
		},
		//-----------------------------------------------------------------------

		/* タスクの並列処理
		 ---------------------------------------------------*/
		parallelize: {
    		typescript: {
      			base: 4
			},
  			coffee: {
      			compile: 4,
      			compileAll: 4
			},
  			compass: {
      			dist: 4
			},
			sprite: {
				all: 4
			}
		}
	});

	// gruntコマンドを打つと走るタスクです。
	grunt.registerTask('default', ['sass','jade','csscss','browserify:lib','browserify:dist','autoprefixer','concat','uglify','cssmin']);
	// grunt cssコマンドを打つと走るタスクです。browserifyによってlib.jsを出力します。
	grunt.registerTask('makelib',['browserify:lib']);
	// grunt cssコマンドを打つと走るタスクです。csscssによってスタイルの重複を出力します。
	grunt.registerTask('csscss', ['csscss']);
	// grunt spriteコマンドを打つと走るタスクです。csscssによってスタイルの重複を出力します。
	grunt.registerTask('sprite', ['sprite:all']);
	// grunt startコマンドを打つと走るタスクです。初期構築を行います。
	grunt.registerTask('start', ['copy','rename','clean:prepare']);
	// grunt watch_filesコマンドを打つと走るタスクです。ファイルの監視・livereloadを行います。
	grunt.registerTask('watch_files', ['open','livereloadx','esteWatch']);
	// grunt lintコマンドを打つと走るタスクです。css/jsにlint/hintを走らせます。
	grunt.registerTask('lint', ['csslint','jshint']);
	// grunt checkコマンドを打つと走るタスクです。css/jsをチェックします。
	grunt.registerTask('check', ['csscss','csslint','jshint']);
	// grunt styleコマンドを打つと走るタスクです。styleguideを作成します。
	grunt.registerTask('style', ['kss']);

	// jit-gruntを使用したプラグイン読み込み）
	require('jit-grunt')(grunt);
};
