require_relative 'lib/smokeymonkey'

env = {}
env[:consumer_key] = ENV['TWITTER_CONSUMER_KEY']
env[:consumer_secret] = ENV['TWITTER_CONSUMER_SECRET']
env['REDISCLOUD_URL'] = ENV['REDISCLOUD_URL']

s = Smokeymonkey.new(env)

desc "fetch backward"
task :backward do
  s.backward
end

desc "fetch forward"
task :forward do
  s.forward
end
