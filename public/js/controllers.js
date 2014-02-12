'use strict';

/* Controllers */

var smokeymonkeyControllers = angular.module('smokeymonkeyControllers', []);

smokeymonkeyControllers.controller('ItemListCtrl', ['$scope', '$http',
  function($scope, $http) {
    $http.get('items/smokeymonkey_meal_tweet.json').success(function(data) {
      $scope.items = data;
    });

    $scope.orderProp = 'id';
    $scope.reverse = true;
  }]);
