watchify = require 'watchify'
browserify = require 'browserify'
gulp = require 'gulp'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
$ = require('gulp-load-plugins')()

gulp.task 'sass', ->
  gulp.src 'client/styles/style.scss'
    .pipe $.plumber()
    .pipe $.sourcemaps.init laadMaps: true
    .pipe $.sass(
      outputStyle: 'compressed'
      includePaths: ['node_modules/foundation-sites/scss']
    ).on 'error', $.sass.logError
    .pipe $.sourcemaps.write './'
    .pipe gulp.dest 'public'

watching = false
gulp.task 'enable-watch-mode', -> watching = true

gulp.task 'browserify', ->
  b = browserify Object.assign {}, watchify.args,
    entries: 'client/index.js'
    debug: true

  bundle = ->
    b
      .transform 'babelify'
      .transform 'uglifyify', global: true
      .bundle()
      .on 'error', (err) ->
        $.util.log 'Browserify Error', err.codeFrame
      .pipe source 'bundle.js'
      .pipe buffer()
      .pipe $.sourcemaps.init loadMaps: true
      .pipe $.sourcemaps.write './'
      .pipe gulp.dest 'public'

  if watching
    w = watchify b
    w.on 'update', bundle
    w.on 'log', $.util.log

  bundle()

gulp.task 'watchify', ['enable-watch-mode', 'browserify']

gulp.task 'watch', ['sass', 'watchify'], ->
  gulp.watch 'client/styles/**/*.scss', ['sass']

gulp.task 'build', ['sass', 'browserify']
