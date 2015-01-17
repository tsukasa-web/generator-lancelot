'use strict';

var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');
var yosay = require('yosay');
var chalk = require('chalk');

var LancelotGenerator = yeoman.generators.Base.extend({
	init: function () {
		this.pkg = require('../package.json');

		this.on('end', function () {
			if (!this.options['skip-install']) {
				this.installDependencies();
			}
		});
	},

	askFor: function () {
		var done = this.async();

		// have Yeoman greet the user.
		console.log(this.yeoman);

		var prompts = [
			{
				name: 'user_name',
				message: 'What is your name ? default(user_name)',
				default: 'user_name'
			},
			{
				name: 'localhost',
				message: 'Input project/localhost name default(localhost)',
				default: 'localhost'
			},
			{
				name: 'rootDirectory',
				message: 'Input rootDirectory name default(docs)',
				default: 'docs'
			},
			{
				type: 'confirm',
				name: 'fontawesome',
				message: 'Do you use font-awesome? default(Yes)',
				default: 'Y/n'
			},
			{
				name: 'common',
				message: 'What is common resource directory name? default(common)',
				default: 'common'
			},
			{
				name: 'compile',
				message: 'What is compile files directory name? default(compile)',
				default: 'compile'
			},
			{
				name: '_documents',
				message: 'What is documents directory name? default(_documents)',
				default: '_documents'
			}
		];

		this.prompt(prompts, function (props) {
			this.user_name = props.user_name;
			this.localhost = props.localhost;
			this.rootDirectory = props.rootDirectory;
			this.fontawesome = props.fontawesome;
			this.sprite = props.sprite;
			this.jqueryversion = props.jqueryversion;
			this.common = props.common;
			this.compile = props.compile;
			this._documents = props._documents;
			done();
		}.bind(this));
	},

	app : function () {
		this.mkdir(this.rootDirectory);
		this.mkdir(this.rootDirectory + '/' + this.common);
		this.mkdir(this.rootDirectory + '/' + this.common + '/css');
		this.mkdir(this.rootDirectory + '/' + this.common + '/js');
		this.mkdir(this.rootDirectory + '/' + this.common + '/css' + '/dest');
		this.mkdir(this.rootDirectory + '/' + this.common + '/js' + '/dest');
		this.mkdir(this.rootDirectory + '/' + this.common + '/img');
		this.mkdir(this.rootDirectory + '/' + this.common + '/img' + '/sprite');
		this.mkdir(this.rootDirectory + '/' + this.common + '/lib');
		if(this.fontawesome){
			this.mkdir(this.rootDirectory + '/' + this.common + '/fonts');
		}
		this.mkdir(this.rootDirectory + '/' + this.common + '/' + this.compile);
		this.mkdir(this.rootDirectory + '/' + this.common + '/' + this.compile + '/scss');
		this.mkdir(this.rootDirectory + '/' + this.common + '/' + this.compile + '/scss' + '/lib');
		this.mkdir(this.rootDirectory + '/' + this.common + '/' + this.compile + '/coffee');
		this.mkdir(this.rootDirectory + '/' + this.common + '/' + this.compile + '/coffee' + '/assets');
		this.mkdir(this.rootDirectory + '/' + this.common + '/' + this.compile + '/coffee' + '/vender');
		this.directory('coffee', this.rootDirectory + '/' + this.common + '/' + this.compile + '/coffee');
		this.mkdir(this.rootDirectory + '/' + this.common + '/' + this.compile + '/jade');
		this.mkdir(this.rootDirectory + '/' + this.common + '/' + this.compile + '/jade' + '/_parts');
		this.mkdir(this.rootDirectory + '/' + this.common + '/' + this.compile + '/jade' + '/_templates');
		this.copy('jade/index.jade', this.rootDirectory + '/' + this.common + '/' + this.compile + '/jade' + '/index.jade');
		this.mkdir(this.rootDirectory + '/' + this._documents);
		this.mkdir(this.rootDirectory + '/' + this._documents + '/modules');
		this.mkdir(this.rootDirectory + '/' + this._documents + '/styleguide_temp');
		this.copy('styleguide_temp/index.html', this.rootDirectory + '/' + this._documents + '/styleguide_temp' + '/index.html');
		this.directory('styleguide_temp/public', this.rootDirectory + '/' + this._documents + '/styleguide_temp' + '/public');

		this.directory('scss/core', this.rootDirectory + '/' + this.common + '/' + this.compile + '/scss' + '/core');
		this.directory('scss/modules', this.rootDirectory + '/' + this.common + '/' + this.compile + '/scss' + '/modules');
		this.directory('scss/lib', this.rootDirectory + '/' + this.common + '/' + this.compile + '/scss' + '/lib');
		this.copy('scss/_core.scss', this.rootDirectory + '/' + this.common + '/' + this.compile + '/scss' + '/_core.scss');
		this.copy('scss/_module.scss', this.rootDirectory + '/' + this.common + '/' + this.compile + '/scss' + '/_module.scss');
		this.copy('scss/style.scss', this.rootDirectory + '/' + this.common + '/' + this.compile + '/scss' + '/style.scss');

		this.template('_Gruntfile.js','Gruntfile.js');
		this.template('_package.json','package.json');
		this.template('_bower.json','bower.json');
		this.template('bowerrc','.bowerrc');
	},

	projectfiles: function () {
		this.copy('editorconfig', '.editorconfig');
		this.copy('jshintrc', '.jshintrc');
	}
});

module.exports = LancelotGenerator;