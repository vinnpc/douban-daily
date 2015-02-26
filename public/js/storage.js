angular.module('yikeApp').factory('storage', function($http, $injector) {

    return $http.get('/api/columns')
    .then(function() {
      return $injector.get('api');
    });
  })
  .factory('api', function($http) {
    var store = {
      columns: [],
      previews: [[]],
      allLoaded: false,
      columnPage: 0,

      getColumns: function() {
        return $http.get('/api/columns')
        .then(function(res) {
          res.data.unshift({
            name: '时间线',
            id: '0'
          });
          angular.copy(res.data, store.columns);
          return store.columns;
        });
      },

      getPreviews: function(columnId) {
        store.allLoaded = false;
        store.columnPage = 0;
        if (columnId == 0) {
          var url = '/api/stream/current';
        } else {
          var url = '/api/column/' + columnId + '/posts';
        }
        return $http.get(url)
          .then(function(res) {
            angular.copy([res.data], store.previews);
            return store.previews;
          });
      },

      getPreviewsByDate: function(date) {
        return $http.get('/api/stream/date/' + date)
        .then(function(res) {
          if (!!res.data.length) {
            store.previews.push(res.data);
          } else {
            store.allLoaded = true;
          }
          return store.previews;
        });
      },

      getColumnPreviewsByPage: function(columnId, page) {
        var url = '/api/column/' + columnId + '/posts/' + page;
        return $http.get(url)
        .then(function(res) {
          if (!!res.data.length) {
            store.previews.push(res.data);
          } else {
            store.allLoaded = true;
          }
          return store.previews;
        });
      },

      checkAllLoaded: function () {
        return store.allLoaded;
      }
    };
    return store;
  });
