require 'twitter'
module Prugins
class TwitterPlugin
  include Cinch::Plugin
  set :prefix, PREFIX
  match /tw (.+)/, method: :twit
  match /twn (\d+) (.+)/, method: :twitn
  match /twl ([A-Za-z]{2}) (.+)/, method: :twitl


  def twitter s, opts = {}
    Twitter.search(s, {result_type: 'recent'}.merge(opts)).map do |r|
#    res = Twitter::Search.new.containing(s).result_type(:recent).per_page(n).map do |r|
      D.decode "#{r.from_user}: #{r.text}".gsub(/(?:\s|<br\/>|<br \/>|<br>)+/,' ')
    end.join('; ')
  rescue
    "#{$!.class}: #{$!.message}; #{$!.backtrace[0]}"
  end

  def twit(m, word)
    m.reply(twitter(word, rpp: 3) || "No results found")
  end

  def twitn(m, num, word)
    m.reply(twitter(word, rpp: num) || "No results found") 
  end
 
  def twitl(m, lang, word)
    m.reply(twitter(word, rpp: 3, lang: lang) || "No results found")
  end
end
end
