#!/usr/bin/env ruby
require 'cinch'
require 'pry'
require 'yaml'
require 'htmlentities'
require 'mechanize'

PREFIX = /^\./

dir = File.dirname(File.expand_path(__FILE__))
Dir.chdir dir
$: << "#{dir}/plugins"
%w[
  google urban_dict twitter
  downforeveryone messageservice
  markovchat markov isgd].each {|f|
  require "./plugins/#{f}"
}

#file is not read unless the database doesn't exist
$mcfile = File.expand_path('./plugins/log.txt')
$new_lines = [] # set to false or nil and new lines will not be saved in the log $mcfile

MC = MarkovChat.new('markov-pry.db')

if !File.exists?('markov-pry.db') \
&& File.exists?($mcfile) \
&& File.size($mcfile) > 0 #overkill?
  puts 'Building markov chain out of ' << $mcfile
  File.readlines($mcfile).each { |l| MC.add_sentence(l) }
end

#MC = MarkovChain.new(File.read($mcfile))
#MC.track_new_shit
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
      Google, UrbanDictionary, IsgdLink, #BabblePlugin,
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
  MC.save #e
  File.open($mcfile, 'a') do |f| #a
    f.puts $new_lines.join("\n") #t
  end if $new_lines #m
end #e

puts 'thanks for playing'
