require 'nokogiri'
require 'open-uri'

class DownForEveryonePlugin
  include Cinch::Plugin
  set :prefix, PREFIX
  match /status (.+)/

  def status site = nil
    url = "http://downforeveryone.com/#{site}"
    res = Nokogiri::HTML(open(url))
    case res.at('div#container').children[2].text.strip
    when /not just you/
      "#{site} appears to be down ( #{url} )"
    when /it's just you/
      "#{site} is up ( #{url} )"
    end
  rescue
    "Something went wrong: #{$!.message}"
  end

  def execute(m, site)
    m.reply status(site)
  end
end
