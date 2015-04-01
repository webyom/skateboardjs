gulp = require 'gulp'
amdBundler = require 'gulp-amd-bundler'

gulp.task 'amd-bundle', ->
	gulp.src([
			'src/main.coffee'
		]).pipe amdBundler()
		.pipe gulp.dest('./dist')

gulp.task 'build', ['amd-bundle']
gulp.task 'default', ['build']
