#!/usr/bin/env ruby
require 'cinch'
require 'pry'
require 'yaml'
require 'htmlentities'
require 'mechanize'

begin
  require 'lulzcatz'
rescue LoadError
  puts %q{I won't be lulzin it up for you}
end

#chat command prefix
PREFIX = /^\./

dir = File.dirname(File.expand_path(__FILE__))
Dir.chdir dir
$: << "#{dir}/plugins"
Dir.chdir 'plugins' do Dir.glob '*.cinch2.rb', &method(:require) end

#file is not read unless the database doesn't exist
$mcfile = File.expand_path('./data/log.txt')
$new_lines = [] # set to false or nil and new lines will not be saved in the log $mcfile
$track_links = [] #set to false to not save links and messages from pookie

MC = MarkovChat.new('./data/markov-pry.db')

if !File.exists?('./data/markov-pry.db') \
&& File.exists?($mcfile) \
&& File.size($mcfile) > 0 #overkill?
  puts 'Building markov chain out of ' << $mcfile
  File.readlines($mcfile).each { |l| MC.add_sentence(l.chomp) }
  MC.save
  exit
end

MC.load

A = Mechanize.new
K = YAML.load_file(File.expand_path('./PryBot.yaml'))
D = HTMLEntities.new

PROTECTED = %w[ topics help ]

bot = Cinch::Bot.new do
  configure do |c|
    c.server = K[:settings][:server]
    c.port = K[:settings][:port]
    c.channels = K[:settings][:channels]
    c.nick = K[:settings][:nick]
    c.plugins.plugins = Prugins.constants.map &Prugins.method(:const_get)
  end
  
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
  end if ($new_lines && $new_lines.size > 0) #m
  File.open(File.expand_path('./data/links'), 'a') do |f|
    f.puts $track_links.join("\n")
  end if $track_links && $track_links.size > 0
end #e

puts 'thanks for playing'
