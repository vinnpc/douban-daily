var gulp = require('gulp'),
    clean = require('gulp-clean'),
    sass = require('gulp-ruby-sass'),
    autoprefixer = require('gulp-autoprefixer'),
    mainBowerFiles = require('main-bower-files');


// gulp.task('clean-sass', function () {
//   return gulp.src(['css'], {read: false})
//   .pipe(clean());
// });

gulp.task('sass', function () {
  return sass('sass', {style: 'expanded'})
    .pipe(autoprefixer())
    .pipe(gulp.dest('css'));
});

// gulp.task('clean-vendor', function () {
//   return gulp.src(['vendor'], {read: false})
//   .pipe(clean());
// });

gulp.task('mainbower', /*['clean-vendor'],*/ function () {
  var jsFiles = mainBowerFiles({
    filter: /\.js|map$/i
  });
  var cssFiles = mainBowerFiles({
    filter: /\.css$/i
  });

  gulp.src(cssFiles)
  .pipe(gulp.dest('vendor/css'))

  return gulp.src(jsFiles)
  .pipe(gulp.dest('vendor/js'))
});

gulp.task('clean', function () {
  return gulp.src(['vendor', 'css'], {read: false})
  .pipe(clean());
});

gulp.task('watch', function () {
  gulp.watch('sass/**/*.scss', ['sass']);
  gulp.watch(['bower_components/*', 'bower.json'], ['mainbower']);
});

gulp.task('default', ['clean'], function () {
  gulp.start('mainbower', 'sass', 'watch');
});
