#!/bin/env ruby
#encoding:UTF-8
require "yaml"
require "twitter"
require 'json'

class TwitterSearch

  def initialize
    config_file = File.join('..', 'config', 'twitter_api_conf.yml')
    #puts config_file

    twitter_config = YAML.load(File.open(config_file))
    #puts "#{twitter_config.inspect}"

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = twitter_config['twitter']['consumer_key']
      config.consumer_secret = twitter_config['twitter']['consumer_secret']
      config.oauth_token = twitter_config['twitter']['oauth_token']
      config.oauth_token_secret = twitter_config['twitter']['oauth_token_secret']
    end
  end

  def search
    puts "--- search api ---"
    @client.search("from:smokeymonkey #昼飯 -rt", :count => 3, :result_type => "recent", :include_entities => true).take(1).collect do |tweet|
      puts "=== #{tweet.created_at} ==="
      puts "    #{tweet.user.screen_name}(#{tweet.id}): #{tweet.text}"
      puts "    #{tweet.user.profile_image_url}"
      puts "    image url : #{tweet.urls[0].expanded_url}"
      image = tweet.urls[0].expanded_url

      # Instagramのサムネイル取得方法
      # http://staku.designbits.jp/get-instagram-thumbnail-url/
      # ====
      # example url (612x612)
      # http://instagr.am/p/jantawrSaj/media/?size=l

    end
  end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield max_id
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end

  def get_all_tweets(user)
    puts "--- get_all_tweets ---"
    collect_with_max_id do |max_id|
      options = {:count => 200, :include_rts => true}
      options[:max_id] = max_id unless max_id.nil?
      @client.user_timeline(user, options)
    end
  end

end

twitter_search = TwitterSearch.new
twitter_search.search

time_line = twitter_search.get_all_tweets("smokeymonkey")
time_line.each do |tweet|
  puts tweet.created_at
  puts tweet.text
end
