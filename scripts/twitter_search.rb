#!/bin/env ruby
#encoding:UTF-8
require "yaml"
require "twitter"

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
    @client.search("#hokkathon -rt", :count => 3, :result_type => "recent").take(3).collect do |tweet|
      puts "#{tweet.user.screen_name}: #{tweet.text}"
    end
  end

end

twitter_search = TwitterSearch.new
twitter_search.search
