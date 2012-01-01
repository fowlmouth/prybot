
class MessageServicePlugin
  MESSAGE_LIMIT = 2
  include Cinch::Plugin
  listen_to :message
  prefix PREFIX
  match /tell ([^\s]+) (.+)/, method: :execute
  match /messages?/, method: :info

  def initialize *args
    super *args
    @messages = K[:messages]
  end


  def listen(m)
    if @messages.has_key?(m.user.nick)
      @messages.delete(m.user.nick).each { |_| m.reply "#{m.user.nick}: #{_}" }
    end
  end
  
  def info(m)
    m.reply @messages.size > 0 ? "Have outstanding messages for #{@messages.keys.join(', ')}" : 'No outstanding messages'
  end

  def execute(m, target, msg)
    if target == bot.nick
      m.reply 'I\'ll be sure to tell your mother that.'
    elsif target == m.user.nick
      m.reply 'whatever, crazy'
    else
      @messages[target] ||= []
      if @messages[target].size >= MESSAGE_LIMIT
        m.reply 'There are already too many messages queued for Mr. Popular'
      else
        @messages[target] << "<#{m.user.nick}> #{msg}"
        m.reply 'Message saved, stamp licked, probably lost in the mail already.'
      end
    end
  end
end
