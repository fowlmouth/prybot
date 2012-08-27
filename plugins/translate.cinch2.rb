=begin
require'google_translate'
module INACTIVATIZED
module Prugins
class GoogleTranslate
  include Cinch::Plugin
  set :prefix, PREFIX
  match /translate (\S+) (\S+) (.+)/, method: :trans

  def trans(m, from, to, text)
    m.reply ::Google::Translator.new.translate(from, to, text).join(' // ')
  end
end
end
end
=end