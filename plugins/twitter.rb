require 'twitter'

class TwitterPlugin
  include Cinch::Plugin
  prefix PREFIX
  match /tw (.+)/, method: :twit
  match /twn (\d+) (.+)/, method: :twitn
  match /nick (\S+)/, method: :changenick

def changenick(m, n)
  if bot.nick = n
    m.reply "Do you even think about all the lives you've ruined? Do you even care?"
  end
end

  def twitter s, n = 3
    res = Twitter::Search.new.containing(s).result_type(:recent).per_page(n).map do |r|
      D.decode "#{r.from_user}: #{r.text}".gsub(/(?:\s|<br\/>|<br \/>|<br>)+/,' ')
    end
    res.join('; ')
  rescue
    false
  end

  def twit(m, word)
    m.reply(twitter(word, 3) || "No results found")
  end

def twitn(m, num, word)
  m.reply(twitter(word, num) || "No results found")
end
end
