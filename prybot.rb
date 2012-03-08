#!/usr/bin/env ruby
require 'cinch'
require 'pry'
#require 'george'
#require 'urban_api'
require 'htmlentities'
require 'mechanize'

PREFIX = /^\./

dir = File.dirname(File.expand_path(__FILE__))
Dir.chdir dir
$:<< dir
require './plugins/google'
#require './plugins/babble'
require './plugins/urban_dict'
require './plugins/twitter'
require './plugins/downforeveryone'
require './plugins/messageservice'
require './plugins/markov'
#require 'babble.rb'

$chance = 5000
$last_babble = Time.now.to_i

$mcfile = File.expand_path('./plugins/log.txt')
MC = MarkovChain.new(File.read($mcfile))
MC.track_new_shit
A = Mechanize.new
#K = George.new(
#  './PryBot.george',
#  read_only: false)
K = YAML.load_file(File.expand_path('./PryBot.yaml'))
D = HTMLEntities.new
#U = UrbanAPI.new

PROTECTED = %w[ topics help ]

bot = Cinch::Bot.new do
  configure do |c|
    c.server = K[:settings][:server]
    c.port = K[:settings][:port]
    c.channels = K[:settings][:channels]
    c.nick = K[:settings][:nick]
    c.plugins.plugins = [
      Google, UrbanDictionary, #BabblePlugin,
      TwitterPlugin, DownForEveryonePlugin, MessageServicePlugin, MarkovPlugin]
  end
  
  #helpers do
#    def urbd s
#      res = U.define(s)[0,3].map { |d|
#        D.decode d
#      }
#      res.join '; '
#    end
  #end
#  on :message, /^.ud (.+)$/ do |m, s|
#    m.reply urbd(s)
#  end
  
  on :message, /^#{self.nick}: help(?:\?)?/ do |m|
    m.reply "#{self.bot.nick} is not a pleasure bot, #{m.nick}."
  end
end

trap 'INT' do exit end
trap 'TERM' do exit end

begin
  bot.start
ensure
  File.open($mcfile, 'a') do |f|
    f.puts MC.new_lines.join("\n")
  end
end

puts 'thanks for playing'
