'use strict';

/* Services */

var smokeymonkeyServices = angular.module('smokeymonkeyServices', ['ngResource']);

smokeymonkeyServices.factory('Item', ['$resource',
  function($resource){
    return $resource('items/:itemId.json', {}, {
      query: {method:'GET', params:{itemId:'items'}, isArray:true}
    });
  }]);
