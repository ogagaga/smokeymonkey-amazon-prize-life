require 'rubygems'
require 'json'
require 'redis'
require 'sinatra'

get('/') { open('public/index.html').read }
get('/tweets') do
  if (ENV['REDISCLOUD_URL'])
    redis = Redis.new(url: ENV['REDISCLOUD_URL'])
  else
    redis = Redis.new
  end
  mapped = redis.sort('tweets').map do |id|
    redis.hgetall("status:#{id}")
  end
  JSON.generate(mapped)
end
run Sinatra::Application
