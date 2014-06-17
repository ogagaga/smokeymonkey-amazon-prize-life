# -*- coding: utf-8 -*-
#!/bin/env ruby
#encoding:UTF-8
require "yaml"
require "twitter"
require 'json'
require 'nokogiri'
require 'open-uri'
require 'time'
require 'pp'

class TwitterSearch

  def initialize
    config_file = File.join('..', 'config', 'twitter_api_conf.yml')
    twitter_config = YAML.load(File.open(config_file))

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = twitter_config['twitter']['consumer_key']
      config.consumer_secret = twitter_config['twitter']['consumer_secret']
      config.oauth_token = twitter_config['twitter']['oauth_token']
      config.oauth_token_secret = twitter_config['twitter']['oauth_token_secret']
    end
  end

  def since_id
    @since_id_params = YAML.load(File.open('since_id.yml'))
    @since_id_params['twitter']['since_id']
  end

  def save_since_id
    @since_id_params['twitter']['since_id'] = @last_tweet_id
    open("since_id.yml","w") do |f|
      YAML.dump(@since_id_params, f)
    end
  end

  def dump
    @results.each do |status|
      pp status.to_hash
    end
  end

  def search
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
    collect_with_max_id do |max_id|
      options = {:count => 10, :include_rts => true}
      options[:max_id] = max_id unless max_id.nil?
      @client.user_timeline(user, options)
    end
  end

  def get_user_timeline(loop_number, user_id, count, since_id=nil, maxid=nil)
    maxid = 0
    @data = Array.new
    loop_number.times do |num|
      # >> make_options method にする
      options = {:count => count, :max_id => maxid}
      if num == 0
        options = {:count => count}
      end
      unless since_id.nil?
        options = {:count => count, :since_id => since_id}
      end
      # << make_options method にする
      @results = @client.user_timeline(user_id, options)
      @results.each do |status|
        # puts "(#{status[:created_at]})(#{status[:id]}) #{status[:user][:name]} #{status.text}"
        status_text_extract(status)
        maxid = status[:id]-1
      end
    end
    @data.sort!{ |a, b| a[:date] <=> b[:date] }
    last = @data.count - 1
    @data.each_with_index do |status, index|
      # puts "index:#{index}"
      if last == index
        @last_tweet_id = status[:id]
      end
    end
    # puts @last_tweet_id
  end

  def status_text_extract(status)
    if status.text.match(%r{\#朝飯|\#昼飯|\#晩飯})
      puts "(#{status[:created_at]})(#{status[:id]}) #{status[:user][:name]} #{status.text}"
      unless status.urls[0].nil?
        expanded_url = "#{status.urls[0].expanded_url}"
        unless expanded_url.match(%r{instagram.com}).nil?
          begin
            file = open(expanded_url)
            puts "file:#{file}"
            doc = Nokogiri::HTML(file) do
              # handle doc
            end
            download_image_url = doc.search('//meta[@property="og:image"]/@content').first
          rescue OpenURI::HTTPError => e
            puts "error"
          end
        end
      end

      @data << {
        :date => (Time.parse("#{status.created_at}")).strftime("%Y-%m-%d %H:%M:%S"),
        :id => status[:id],
        :snippet => status.text,
        :imageUrl => download_image_url
      }
    end
  end

  def save(file_name, mode)
    json_data = JSON.parse(File.read(file_name))
    read_data = json_data.collect { |data| data }
    data = read_data.concat(@data)

    File.open(file_name, mode) do |file|
      file.puts JSON.pretty_generate(data)
    end
  end

end

# JSONデータ作成時はsmokeymonkey_meal_tweet.json
# の最後のidに書き換えて実行する
# SINCE_ID = 433913962540044289
LOOP_NUMBER = 1
SEARCH_COUNT = 200
SAVE_FILE = "../public/items/smokeymonkey_meal_tweet.json"
twitter_search = TwitterSearch.new
since_id = twitter_search.since_id
# puts since_id
twitter_search.get_user_timeline(LOOP_NUMBER, "smokeymonkey", SEARCH_COUNT, since_id + 1)
twitter_search.save(SAVE_FILE, "w")
twitter_search.save_since_id
# twitter_search.search
# twitter_search.dump



