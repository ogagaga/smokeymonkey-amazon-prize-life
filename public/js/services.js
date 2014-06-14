'use strict';

/* Services */

var smokeymonkeyServices = angular.module('smokeymonkeyServices', ['ngResource']);

// TODO:一食の詳細情報を表示しようとした場合の残骸で現在未使用
smokeymonkeyServices.factory('Item', ['$resource',
  function($resource){
    return $resource('items/:itemId.json', {}, {
      query: {method:'GET', params:{itemId:'items'}, isArray:true}
    });
  }]);


