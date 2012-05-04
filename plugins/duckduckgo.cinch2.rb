
class DuckDuckGoPlugin
include Cinch::Plugin
set :prefix, '.'
match /^\.ddg (.*)/

res = Net::HTTP.get_response URI.parse(s)
res &&= JSON.parse(res.body)

end
