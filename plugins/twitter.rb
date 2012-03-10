require 'twitter'

class TwitterPlugin
  include Cinch::Plugin
  set :prefix, PREFIX
  match /tw (.+)/, method: :twit
  match /twn (\d+) (.+)/, method: :twitn
  match /twl ([A-Za-z]{2}) (.+)/, method: :twitl
  match /nick (\S+)/, method: :changenick

  def changenick(m, n)
    if bot.nick = n
      m.reply "Do you even think about all the lives you've ruined? Do you even care?"
    end
  end

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
