
class MarkovChain
  attr_reader :words
  
  def self.filter_word(word)
    word = word.gsub(/'|"/, '')
    word.empty? ? nil : word
  end
  
  def initialize(text=nil)
    @words = Hash.new
    @decoder = HTMLEntities.new
    @new_lines, @track_new_shit = [], false
    digest_text(text) if text
  end

  def track_new_shit() @track_new_shit ||= true end
  def new_lines() @new_lines end
  def clear_new_lines() @new_lines = [] end
  
  def digest_text(text)
    # html regex from http://snippets.dzone.com/posts/show/4324
    wordlist = @decoder.decode(text).gsub(/<\/?[^>]*>/, '').split.map { |w| MarkovChain.filter_word(w) }.compact
    @new_lines << wordlist.join(' ') if @track_new_shit
    wordlist.each_with_index do |word, index|
      add(word, wordlist[index + 1]) if index <= wordlist.size - 2
    end
  end
  
  def inspect() "Words: #{@words.size}" end

  def add(word, next_word)
    @words[word] ||= Hash.new(0)
    @words[word][next_word] += 1
  end

  def get(word)
    return random_word if !@words[word]
    followers = @words[word]
    sum = followers.inject(0) {|sum,kv| sum += kv[1]}
    random = rand(sum)+1
    partial_sum = 0
    next_word = followers.find do |word, count|
      partial_sum += count
      partial_sum >= random
    end.first
    next_word
  end
  
  def random_word
    @words.keys[rand(@words.size)]
  end
  
  def add_sentence sentence
    sentence = sentence.split
    sentence.each_with_index do |word, index|
      add(word, sentence[index+1]) if index <= sentence.size-2
    end
  end
=begin  
  def add_rss feed = 'http://rss.cnn.com/rss/money_news_economy.rss'
    rss = SimpleRSS.parse open(feed)
    rss.entries.each do |e| 
      digest_text e[:title]
      digest_text e[:description]
    end
    true
  end
=end
end

class MarkovPlugin
  include Cinch::Plugin
  match /(.*)/, method: :om_nom_nom, use_prefix: false
  match /^\.mc-info/, method: :mc_info, use_prefix: false
  match /^\.mc-save/, method: :mc_save, use_prefix: false

  def om_nom_nom m, s
    if s =~ /^#{bot.nick}(,|:)/
      puts 'I should babel...'
      m.reply MC.chat
    else
      puts "Adding text: #{s}"
      MC.add_sentence s
    end
  end

def mc_save m
  MC.background_save
  (m.reply "Database saved, log unchanged"; return) unless $new_lines
  File.open($mcfile, 'a') do |f|
    f.puts $new_lines.join("\n")
  end
  $new_lines = []
  m.reply "File saved, #{mc_fsize}"
end

def mc_fsize
  s = File.size $mcfile
  if s < 1024
    "#{s} KB"
  elsif s < 1024**2
    "#{((s*1.0)/(1024**2)).round(2)} MB"
  elsif s < 1024**3
    "#{((s*1.0)/(1024**3)).round(2)} GB"
  end
end

  def mc_info m
    m.reply MC.inspect
  end

def sentence word='I', size=1
  sentence = ''
  word = MC.random_word if word.nil? || MC.get(word).nil?
  until sentence.count('.') == size || sentence.size > 420 
    sentence << word << ' '
    word = MC.get(word)
  end
  sentence
end

end

