var app = angular.module('yikeApp', ['ngAnimate', 'ngRoute']);

app.config(function ($routeProvider) {

  var routeConfig = {
    controller: 'yikeCtrl',
    templateUrl: 'yike-index.html',
    resolve: {
      store: function (storage) {
        return storage.then(function (module) {
          return module.getColumns().then(function () {
            return module;
          })
        });
      },
      runtimeStore: function (runtimeStorage) {
        return runtimeStorage;
      }
    }
  };

  $routeProvider
    .when('/', routeConfig)
    .when('/column/:columnId', routeConfig)
    .otherwise({
      redirectTo: '/'
    });
});
