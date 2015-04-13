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
					
		watch:
			livereload:
				options:
					livereload: '<%= connect.options.livereload %>'
				
	grunt.registerTask 'serve', 'Compile then start a connect web server', ->
		grunt.task.run [
			'connect:livereload'
		]