require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
module Prugins
class UrbanDictionary
  include Cinch::Plugin

  set :prefix, PREFIX
  match /urban (.+)/
  def lookup(word)
    url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}"
    res = CGI.unescape_html Nokogiri::HTML(open(url)).at("div.definition").text.gsub(/\s+/, ' ') rescue nil
    if res.nil?
      "No results found."
    elsif res.size < 300
      res
    else
      res[0,300] << '... ' << url
    end
  end

  def execute(m, word)
    m.reply lookup(word), true
  end
end
end

