# Grunt configuration updated to latest Grunt. That means your minimum
# version necessary to run these tasks is Grunt 0.4.
#
# Please install this locally and install `grunt-cli` globally to run.
module.exports = (grunt) ->
	
	# Load grunt tasks automatically
	require('load-grunt-tasks')(grunt)
	# Time how long tasks take. Can help when optimizing build times
	require('time-grunt')(grunt)
	
	appConfig =
		app: require('./bower.json').appPath or 'public'
	
	# Initialize the configuration.
	grunt.initConfig
	
		appConfig: appConfig
		
		connect: 
			options:
				port: 9000,
				hostname: '0.0.0.0'
				livereload: 35729
			livereload:
				options:
					keepalive: true
					open: true
					base: 'public'
					
		less:
			options:
				paths: [
					'<%= appConfig.app %>/bower_components',
					'<%= appConfig.app %>/less'
				]
			main:
				files:
					'<%= appConfig.app %>/css/main.css':'<%= appConfig.app %>/less/main.less'
					
		coffee:
			main:
				expand: true
				cwd: '<%= appConfig.app %>/coffee/'
				src: [
					'**/*.coffee'
				]
				dest: '<%= appConfig.app %>/js/'
				ext: '.js'
					
		wiredep:
			main:
				src: '<%= appConfig.app %>/*.html'
				exclude: [
					/bootstrap-sass-official/,
					/bootstrap.js/,
					'/json3/',
					'/es5-shim/',
					/bootstrap.css/,
					/font-awesome.css/,
					/common\/.*\.css/,
					/modernizr.js/
				]
				
		injector:
			scripts:
				options:
					transform: (filePath) ->
						filePath = filePath.replace '/public/', ''
						filePath = filePath.replace '/.tmp/', ''
						"<script src=\"#{filePath}\"></script>"
					starttag: '<!-- injector:js -->'
					endtag: '<!-- endinjector -->'
				files:
					'<%= appConfig.app %>/index.html': [
						'{.tmp,<%= appConfig.app %>}/js/**/*.js',
						'!{.tmp,<%= appConfig.app %>}/js/main.js',
						'!{.tmp,<%= appConfig.app %>}/js/**/*.spec.js',
						'!{.tmp,<%= appConfig.app %>}/js/**/*.mock.js'
					]
						
			less:
				options:
					transform: (filePath) ->
						filePath = filePath.replace '/public/less/', ''
						"@import '#{filePath}';"
					starttag: '// injector'
					endtag: '// endinjector'
				files:
					'<%= appConfig.app %>/less/main.less': [
						'{.tmp,<%= appConfig.app %>}/less/**/*.less',
						'!{.tmp,<%= appConfig.app %>}/less/main.less'
					]
			
			css:
				options:
					transform: (filePath) ->
						filePath = filePath.replace '/public/', ''
						filePath = filePath.replace '/.tmp/', ''
						"<link rel=\"stylesheet\" href=\"#{filePath}\">"
					starttag: '<!-- injector:css -->'
					endtag: '<!-- endinjector -->'
				files:
					'<%= appConfig.app %>/index.html': [
						'{.tmp,<%= appConfig.app %>}/css/**/*.css',
						'!{.tmp,<%= appConfig.app %>}/css/normalize{,.min}.css'
					]
		watch:
			bower:
				files: ['bower.json']
				tasks: ['wiredep']
			js:
				files: '<%= appConfig.app %>/js/{,*/}*.js'
				options:
					livereload: '<%= connect.options.livereload %>'
			css:
				files: '<%= appConfig.app %>/css/{,*/}*.css'
				options:
					livereload: '<%= connect.options.livereload %>'
			less:
				files: ['<%= appConfig.app %>/less/**/*.less']
				tasks: ['less']
			coffee:
				files: ['<%= appConfig.app %>/coffee/**/*.coffee']
				tasks: ['coffee']
			livereload:
				options:
					livereload: '<%= connect.options.livereload %>'
				files: [
					'<%= appConfig.app %>/{,*/}*.html',
					'.tmp/css/{,*/}*.css',
					'<%= appConfig.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
				]
		
				
	grunt.registerTask 'serve', 'Compile then start a connect web server', ->
		grunt.task.run [
			'wiredep',
			'injector',
			'less',
			'coffee',
			'connect:livereload',
			'watch'
		]