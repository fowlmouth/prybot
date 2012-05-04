require'json'
require'open-uri'
require'ampex'

class GemSearch
  include Cinch::Plugin
  set :prefix, PREFIX
  match /gem (\S+)/, method: :gemsearch
  GemUrl = 'http://rubygems.org/api/v1/search.json?query=%s'

  def gemsearch(m, query)
    res = JSON(open(GemUrl % query, &X.read))
    m.reply (!res.is_a?(Array) || res.empty?) ? 
      'No results'                            :
      "#{res.size} results: #{res.map{|r|r['name']}.join(', ')}"
  rescue
    m.reply "Something exploded"
  end
end
