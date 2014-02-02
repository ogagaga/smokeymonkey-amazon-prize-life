#!/bin/env ruby
#encoding:UTF-8
require "yaml"
require "twitter"
require 'json'
require 'nokogiri'
require 'open-uri'
require 'pp'

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

  def dump
    @results.each do |status|
      pp status.to_hash
    end
  end

  def search
    pp "--- search api ---"

    search_word = "from:smokeymonkey #朝飯 OR #昼飯 OR #晩飯 -rt"
    @results = @client.search(search_word, :count => 5, :result_type => "recent", :include_entities => true)
    @results.each_with_index do |tweet, index|
      puts "=== #{tweet.created_at} ==="
      puts "#{tweet.user.screen_name}(#{tweet.id}): #{tweet.text}"

      data = Array.new
      data << {
        :created_at => "#{tweet.created_at}",
        :no => index ,
        :id => "relief-goods-#{"%02d" % index}",
      }
      puts JSON.pretty_generate(data)
      # File.open("./temp.json","w") do |f|
      #   f.write(JSON.pretty_generate(data))
      # end

      if tweet.urls[0].nil?
        puts "tweet.urls[0].expanded_url is not match to instagram"
        next
      end

      puts "expanded_url:#{tweet.urls[0].expanded_url}"
      expanded_url = "#{tweet.urls[0].expanded_url}"

      if expanded_url.match(%r{instagram.com}).nil?
        next
      end

      doc = Nokogiri::HTML(open(expanded_url))
      download_image_url = doc.search('//meta[@property="og:image"]/@content').first
      puts "#{download_image_url}"
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
      options = {:count => 10, :include_rts => true}
      options[:max_id] = max_id unless max_id.nil?
      @client.user_timeline(user, options)
    end
  end

  def get_user_timeline(loop_number, user_id, count)
    maxid = 0
    @results = @client.user_timeline(user_id, :count => count)
    @results.each do |status|
      str = "(#{status[:created_at]})(#{status[:id]}) #{status[:user][:name]} #{status.text}"
      puts str
      maxid = status[:id]-1
      # pp status.to_hash
      save(@results, "../app/items/smokeymonkey_tweet.json", "a")
    end

    loop_number.times {
      @results = @client.user_timeline(user_id, :count => count,:max_id => maxid)
      @results.each do |status|
        str = "(#{status[:created_at]})(#{status[:id]}) #{status[:user][:name]} #{status.text}"
        puts str
        maxid = status[:id]-1
        save(@results, "../app/items/smokeymonkey_tweet.json", "a")
      end
    }
  end

  def save(obj, file_name, mode)
    File.open(file_name, mode) { |file|
      obj.each do |status|
        file.puts status.to_hash.to_json
      end
    }
  end

  def run_search
    # tweet取得

    # 画像ダウンロード
    
    # json書き込み
  end

end

twitter_search = TwitterSearch.new
twitter_search.get_user_timeline(7, "smokeymonkey", 200)
# twitter_search.search
# twitter_search.dump



