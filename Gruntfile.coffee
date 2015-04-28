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
		app: require('./bower.json').appPath or 'app'
	
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
					open: true
					base: 'app'
					
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
					
		assemble:
			options:
				flatten: true
				layout: 'index.hbs'
				layoutdir: '<%= appConfig.app %>/templates/layouts'
				partials: ['<%= appConfig.app %>/templates/partials/*.hbs']
				assets: '<%= appConfig.app %>/images'
				
			app:
				files:
					'<%= appConfig.app %>/':'<%= appConfig.app %>/templates/pages/*.hbs'
				
				
		injector:
			scripts:
				options:
					transform: (filePath) ->
						filePath = filePath.replace '/app/', ''
						"<script src=\"#{filePath}\"></script>"
					starttag: '<!-- injector:js -->'
					endtag: '<!-- endinjector -->'
				files:
					'<%= appConfig.app %>/templates/partials/footer.hbs': [
						'<%= appConfig.app %>/js/**/*.js',
						'!<%= appConfig.app %>/js/main.js',
						'!<%= appConfig.app %>/js/**/*.spec.js',
						'!<%= appConfig.app %>/js/**/*.mock.js'
					]
						
			less:
				options:
					transform: (filePath) ->
						filePath = filePath.replace '/app/less/', ''
						"@import '#{filePath}';"
					starttag: '// injector'
					endtag: '// endinjector'
				files:
					'<%= appConfig.app %>/less/main.less': [
						'<%= appConfig.app %>/less/**/*.less',
						'!<%= appConfig.app %>/less/main.less'
					]
			
			css:
				options:
					transform: (filePath) ->
						filePath = filePath.replace '/app/', ''
						"<link rel=\"stylesheet\" href=\"#{filePath}\">"
					starttag: '<!-- injector:css -->'
					endtag: '<!-- endinjector -->'
				files:
					'<%= appConfig.app %>/templates/partials/header.hbs': [
						'<%= appConfig.app %>/css/**/*.css',
						'!<%= appConfig.app %>/css/normalize{,.min}.css'
					]
						
		svgmin:
			options:
				plugins: [
					removeRasterImages: true
				]
			main:
				files: [
					expand: true,
					cwd: '<%= appConfig.app %>/images/src/svg'
					src: '*.svg'
					dest: '<%= appConfig.app %>/images/dist/svg'
					ext: '.svg'
				]
		
		webfont:
			main:
				src: '<%= appConfig.app %>/images/dist/svg/*.svg'
				dest: '<%= appConfig.app %>/fonts/'
				templateOptions:
					baseClass: 'd-glyphicon'
					classPrefix: 'd-glyphicon-'
					mixinPrefix: 'dGlyphicon-'
					
		sprite:
			main:
				src: '<%= appConfig.app %>/images/sprites/*.png'
				retinaSrcFilter: '<%= appConfig.app %>/images/sprites/*-2x.png'
				dest: '<%= appConfig.app %>/images/spritesheet.png'
				retinaDest: '<%= appConfig.app %>/images/spritesheet-2x.png'
				imgPath: 'images/spritesheet.png'
				retinaImgPath: 'images/spritesheet-2x.png'
				destCss: '<%= appConfig.app %>/less/spritesmith/sprites.less'
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
			assemble:
				files: '<%= appConfig.app %>/templates/**/*.hbs'
				tasks: ['assemble']
			livereload:
				options:
					livereload: '<%= connect.options.livereload %>'
				files: [
					'<%= appConfig.app %>/{,*/}*.html',
					'<%= appConfig.app %>/css/{,*/}*.css',
					'<%= appConfig.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
				]
		
				
	grunt.registerTask 'serve', 'Compile then start a connect web server', ->
		grunt.task.run [
			'wiredep',
			'injector',
			'less',
			'coffee',
			'svgmin',
			'webfont',
			'sprite',
			'connect:livereload',
			'watch'
		]