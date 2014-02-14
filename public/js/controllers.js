'use strict';

/* Controllers */

var smokeymonkeyControllers = angular.module('smokeymonkeyControllers', []);

smokeymonkeyControllers.controller('ItemListCtrl', ['$scope', '$http',
  function($scope, $http) {
    $http.get('items/smokeymonkey_meal_tweet.json').success(function(data) {
      $scope.items = data;
      var getItems = $scope.items;
      $scope.items = [];
      angular.forEach(getItems, function(item) {
        if (!item.imageUrl) {
          item.imageUrl = "./images/no-image.JPG"
          // console.dir(item);
        }
        $scope.items.push(item);
      });
    });

    $scope.orderProp = 'id';
    $scope.reverse = true;
    $scope.query = '';
  }]);
