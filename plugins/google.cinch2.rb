require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require'json'

module Prugins
class Google
  include Cinch::Plugin

  set :prefix, PREFIX
  match /google (.+)/, method: :searchc
  match /time (.+)/, method: :gtimec
  match /suggest (.+)/, method: :"epitron^_^"

  def gtime s
    res = ''
    A.get("http://google.com/pda?q=time+in+#{s.gsub(/\s+/, '+')}") do |p|
      p.search('span.no8s2k').children.each { |c| res << c.text }
    end
    res
  rescue
    'Some problem'
  end

  def gtimec m, s
    s[0,2] = '' if s[0,2] == 'in'
    m.reply gtime(s)
  end

  def search(query)
    url = "http://www.google.com/search?q=#{CGI.escape(query)}"
    res = Nokogiri::HTML(open(url)).at("h3.r")

    title = res.text
    link = res.at('a')[:href]
    desc = res.at("./following::div").children.first.text
    CGI.unescape_html "#{title} - #{desc} (#{link})"
  rescue
    "No results found"
  end

  def searchc(m, query)
    m.reply(search(query))
  end

  define_method :"epitron^_^" do |m, query|
    begin
      res = JSON(open('http://suggestqueries.google.com/complete/search?client=firefox&q='+(URI.encode query), &:read)).last
      if res.empty? then m.reply 'I\'m all out of suggestions.'
      else m.reply res.join(' | ') end
    rescue => e
      m.reply 'Something bad happened: ' << e.class.to_s << ': ' << e.message
    end 
  end
end
end
