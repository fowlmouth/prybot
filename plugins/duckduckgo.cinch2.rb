
class DuckDuckGoPlugin
include Cinch::Plugin
set :prefix, '.'
match /^\.ddg (.*)/

def execute(m, *)
m.reply "apparently i stopped half way through writing the duckduckgo plugin"
end

=begin
res = Net::HTTP.get_response URI.parse(s)
res &&= JSON.parse(res.body)
=end
end
