require 'net/http'
require 'uri'

module Prugins
class IsgdLink
  include Cinch::Plugin
  set :prefix, PREFIX
  match /isgd (\S+)/, method: :isdg
  match /tinyurl (\S+)/, method: :isgd
  match /shorten (\S+)/, method: :isgd
  ISGD = 'http://is.gd/create.php?format=simple&url=%s'

  def isgd(m, word)
    res = Net::HTTP.get_response URI.parse(ISGD % D.encode(word))
    res && res.code == '200' && m.reply("#{m.user.nick}: #{res.body}")
  end
end
end

