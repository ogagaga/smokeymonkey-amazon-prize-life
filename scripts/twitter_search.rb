#!/bin/env ruby
#encoding:UTF-8
require "yaml"
require "twitter"

config_file = File.join('..', 'config', 'twitter_api_conf.yml')
#puts config_file
TWITTER_CONFIG = YAML.load(File.open(config_file))
#puts "#{TWITTER_CONFIG.inspect}"

client = Twitter::REST::Client.new do |config|
  config.consumer_key = TWITTER_CONFIG['twitter']['consumer_key']
  config.consumer_secret = TWITTER_CONFIG['twitter']['consumer_secret']
  config.oauth_token = TWITTER_CONFIG['twitter']['oauth_token']
  config.oauth_token_secret = TWITTER_CONFIG['twitter']['oauth_token_secret']
end

# client.update("Testツイート:I'm tweeting with @gem!")

client.search("#hokkathon -rt", :count => 3, :result_type => "recent").take(3).collect do |tweet|
  puts "#{tweet.user.screen_name}: #{tweet.text}"
end

# # for Streaming
# client = Twitter::Streaming::Client.new do |config|
#   config.consumer_key = TWITTER_CONFIG['twitter']['consumer_key']
#   config.consumer_secret = TWITTER_CONFIG['twitter']['consumer_secret']
#   config.oauth_token = TWITTER_CONFIG['twitter']['oauth_token']
#   config.oauth_token_secret = TWITTER_CONFIG['twitter']['oauth_token_secret']
# end

# topics = ["coffee", "tea"]
# client.filter(:track => topics.join(",")) do |object|
#   puts object.text if object.is_a?(Twitter::Tweet)
# end
