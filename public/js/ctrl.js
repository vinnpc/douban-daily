app.controller('yikeCtrl', function yikeCtrl($rootScope, $scope, $routeParams, $sce, store, runtimeStore) {
  $scope.lastDay = ''
  $scope.currentPage = 0;
  $scope.busy = true;
  $scope.columns = store.columns;

  // column id
  $scope.currentColumnId = exist($routeParams.columnId) ?
    $routeParams.columnId : 0;

  // get preview;
  store.getPreviews($scope.currentColumnId).then(function () {
    $scope.busy = false;
    $scope.previews = store.previews;
    scrollEven();

    $scope.lastDay = store.previews[0][0].date;
    $scope.currentPage = 0;

    // show first post
    if (runtimeStore.showingPostUrl == '' && exist(store.previews[0][0])) {
      runtimeStore.showingPostUrl = store.previews[0][0].url;
      $rootScope.showingPostUrl = $sce.trustAsResourceUrl(runtimeStore.showingPostUrl);
    }
  });

  // formatDate
  // return {date:'', mon:''}
  $scope.formatDate = function (dateStr) {
    var d = new Date(dateStr),
        utcStr = d.toUTCString();
    var result = {
      date: d.getDate(),
      mon: utcStr.slice(8, 11)
    }
    return result;
  };

  // change iframe src
  $scope.showPost = function (url) {
    runtimeStore.showingPostUrl = url;
    $rootScope.showingPostUrl = $sce.trustAsResourceUrl(runtimeStore.showingPostUrl);
  };

  // scroll even
  var scrollEven = function () {
    var pContainer = angular.element('.l-preview'),
        pInner = angular.element('.l-preview-inner'),
        distance = 600;

    pContainer.on('scroll', function() {

      if (!$scope.busy && !store.checkAllLoaded() &&
        pInner.height() - distance < pContainer.height() + pContainer.scrollTop()) {
          loadMore();
      }
    });
  }

  // load more previews
  var loadMore = function () {
    $scope.busy = true;

    if ($scope.currentColumnId == 0) {
      var yesterday = getYesterday($scope.lastDay);
      store.getPreviewsByDate(yesterday)
        .then(function () {
          $scope.lastDay = yesterday
          $scope.busy = false;
        });
    } else {
      store.getColumnPreviewsByPage($scope.currentColumnId, $scope.currentPage + 1)
        .then(function () {
          $scope.currentPage += 1;
          $scope.busy = false;
        });
    }
  };

});

var getYesterday = function (date) {
  var yesterday = new Date(new Date(date) - 24 * 60 * 60 * 1000),
  result = yesterday.toISOString().slice(0, 10);
  return result;
}

var getNextDay = function (date) {
  var yesterday = new Date(new Date(date) + 24 * 60 * 60 * 1000),
  result = yesterday.toISOString().slice(0, 10);
  return result;
}

var exist = function (target) {
  return typeof target != null && typeof target != 'undefined';
}
