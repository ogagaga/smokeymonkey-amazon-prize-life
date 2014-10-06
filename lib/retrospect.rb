require 'nokogiri'
require 'open-uri'
require 'twitter'

# TODO: Write docs using YARD

class Retrospect
  # @param environment [Hash]
  def initialize(environment)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = environment[:consumer_key]
      config.consumer_secret = environment[:consumer_secret]
    end
  end

  # Display a tweet
  # @param tweet [Twitter::Tweet]
  # @return [void]
  def display(tweet)
    puts "#{tweet.id} #{tweet.created_at} #{tweet.text}"
  end

  # @param tweet [Twitter::Tweet] a tweet
  # @return [Hash]
  def extract(tweet)
    hash = {
      id: tweet.id,
      date: tweet.created_at,
      text: tweet.text,
    }
    image_url = instagram(tweet.urls.first)
    hash.update({ imageUrl: image_url }) if image_url
    hash
  end

  # @param tweet [Twitter::Tweet] tweet
  # @param regexp [Regexp] regular expression
  # @return [Hash, nil]
  def filter(tweet, regexp)
    # TODO: regexpがnilの場合tweet.text.match(regexp)が何を返すか調べること
    tweet.text.match(regexp) ? extract(tweet.tap { |tw| display(tw) }) : nil
  end

  # @param tweets [Array<Twitter::Tweet>] array of tweets
  # @param regexp [Regexp] regular expression
  # @return [Array<Hash>] tweets which are matched by `regexp`
  def filter_tweets(tweets, regexp)
    tweets.map { |tweet| regexp.nil? ? nil : filter(tweet, regexp) }
  end

  def user_timeline(username, regexp = nil, options = {})
    sleep wait_time
    timelines = @client.user_timeline(username, options)
    filter_tweets(timelines, regexp).compact
  end

  # @param username [String] the username in twitter
  # @param regexp [Regexp] regular expression
  # @return [Array<Hash>] user_timeline tweets which are matched by `regexp`
  def filtered_user_timeline(username, regexp = nil)
    result = []

    # user_timeline:
    #   see: http://rdoc.info/gems/twitter/Twitter/REST/Timelines#user_timeline-instance_method
    #   "This method can only return up to 3,200 of a user's most recent Tweets. "
    options = { include_rts: false, count: 200 }
    tweets = 0
    timelines = @client.user_timeline(username, options)
    # TODO: Should I eliminate magic number `3,200`?
    until timelines.empty? or tweets >= 3200
      tweets += timelines.size
      current_chunk = filter_tweets(timelines, regexp).compact
      options.update({ max_id: current_chunk.last[:id] - 1 })
      result += current_chunk
      sleep wait_time
      timelines = @client.user_timeline(username, options)
    end
    result
  end

  # @param url [Twitter::Entity::URI] a url in tweet
  # @return [String, nil] an image url or nil if the given `url` doesn't exist in instagram.com
  def instagram(url)
    return nil if url.nil?

    url = url.expanded_url
    image = nil
    if url.host == 'instagram.com'
      doc = Nokogiri::HTML(open(url))
      image = doc.at_xpath('//meta[@property="og:image"]/@content').value
    end
    image
  end

  # @param method [String]
  # @return [Hash]
  def rate_limit_status(method = '/statuses/user_timeline')
    resource_family, = method.split('/').reject(&:empty?)
    body = @client.get('/1.1/application/rate_limit_status.json',
                       resources: resource_family)[:body]
    hash = body[:resources][resource_family.to_sym][method.to_sym]
    hash.update({ reset: Time.at(hash[:reset]) })
  end

  def tweet(status_id)
    extract(@client.status(status_id))
  end

  # @param method [String]
  # TODO: Write a document on the return value
  def wait_time(method = '/statuses/user_timeline')
    # Rate limits:
    #   see: https://dev.twitter.com/docs/rate-limiting/1.1/limits
    limit = rate_limit_status(method)
    puts limit
    rest = (limit[:reset] - Time.now)
    rest / limit[:remaining]
  end
end
