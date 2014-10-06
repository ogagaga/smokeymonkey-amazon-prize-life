# encoding: utf-8
require 'redis'
require_relative 'retrospect'

class Smokeymonkey
  FIRST_SINCE_ID = '419273573283688448'
  REGEXP = %r{\#朝飯|\#昼飯|\#晩飯}

  def initialize(environment)
    @r = Retrospect.new({ consumer_key: environment[:consumer_key], consumer_secret: environment[:consumer_secret] })
    if environment['REDISCLOUD_URL']
      @redis = Redis.new(url: environment['REDISCLOUD_URL'])
    else
      @redis = Redis.new
    end
  end

  def hmset(tweet)
    id = tweet[:id]
    key = "status:#{id}"
    @redis.pipelined do
      @redis.sadd('tweets', id)
      @redis.mapped_hmset(key, tweet)
    end
  end

  def user_timeline(options)
    @r.user_timeline('smokeymonkey', REGEXP, options).each do |tweet|
      hmset(tweet)
    end
    @redis.scard('tweets')
  end

  def forward
    options = { include_rts: false, count: 200, since_id: since_id }
    user_timeline(options)
  end

  def backward
    options = { include_rts: false, count: 200, max_id: max_id }
    user_timeline(options)
  end

  def sort(options)
    sorted = @redis.sort('tweets', options)
    (sorted.empty? ? FIRST_SINCE_ID : sorted.first).to_i
  end

  def max_id
    sort(limit: [0, 1])
  end

  def since_id
    sort(order: 'desc', limit: [0, 1])
  end
end
