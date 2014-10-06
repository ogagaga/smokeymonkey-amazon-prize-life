'use strict';

/* Controllers */

var smokeymonkeyControllers = angular.module('smokeymonkeyControllers', []);

smokeymonkeyControllers.controller('ItemListCtrl', ['$scope', '$http',
  function($scope, $http) {
    $http.get('/tweets').success(function(tweets) {
      $scope.items = [];
      angular.forEach(tweets, function(tweet) {
        if (!tweet.imageUrl) {
          tweet.imageUrl = "./images/no-image.JPG"
        }
        $scope.items.push(tweet);
      });
    });

    $scope.orderProp = 'id';
    $scope.reverse = true;
    $scope.query = '';
  }]);
