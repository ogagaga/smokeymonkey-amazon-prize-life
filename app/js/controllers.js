'use strict';

/* Controllers */

var smokeymonkeyControllers = angular.module('smokeymonkeyControllers', []);

smokeymonkeyControllers.controller('ItemListCtrl', ['$scope', '$http',
  function($scope, $http) {
    $http.get('items/items.json').success(function(data) {
      $scope.items = data;
    });

    $scope.orderProp = 'no';
  }]);
