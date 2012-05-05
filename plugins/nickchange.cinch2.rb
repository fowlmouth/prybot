module Prugins
class NickChangePlugin
  include Cinch::Plugin
  set :prefix, PREFIX
  match /nick (\S+)/, method: :changenick
  #listen_to :nick, method: :nick_changed
  listen_to Cinch::Constants::ERR_ERRONEUSNICKNAME, method: :wellfuck
  #listen_to Cinch::Constants::ERR_NICKNAMEINUSE, method: :nick_in_use

  def changenick(m, n)
    @lastchanged = m.user.nick
    bot.nick = n
  end

  #def nick_changed(m)
  #  if m.user == @bot
  #    m.reply "Do you even think about all the lives you've ruined? Do you even care?"
  #  end
  #end

  #invalid nick message recieved
  def wellfuck(m)
    if @lastchanged
      #nil it so it hits a random nick next time
      @lastchanged, bot.nick = nil, "#{@lastchanged}_sucks"
    else #this is a connection attempt (this will also probably fire on reconnecting, who cares
      bot.nick = random_nick
    end
  end

  #def nick_in_use(m) bot.nick = random_nick end
  
  def random_nick() (0..8).map { rand(65..90).chr }.join'' end
end
end

