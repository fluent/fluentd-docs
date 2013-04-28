require 'rubygems'
require 'bundler'
Bundler.setup

$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'article'
require 'indextank'

desc 'start a development server'
task :server do
  if which('shotgun')
    exec 'shotgun -O app.rb -p 9395'
  else
    warn 'warn: shotgun not installed; reloading is disabled.'
      exec 'ruby -rubygems app.rb -p 9395'
  end
end
def which(command)
  ENV['PATH'].
    split(':').
    map  { |p| "#{p}/#{command}" }.
    find { |p| File.executable?(p) }
end
task :start => :server

desc 'index documentation'
task :index do
  puts "indexing now:"
  client = IndexTank::Client.new(ENV['SEARCHIFY_API_URL'])
  index = client.indexes('td-docs')
  index.add unless index.exists?

  docs = FileList['docs/*.txt']
  docs.each do |doc|
    name = File.basename(doc, '.txt')
    puts "...indexing #{name}"
    source = File.read(doc)
    topic = Article.load(name, source)
    topic.text_only
    result = indextank_document = index.document(name).add(:title => topic.title, :text => topic.body)
    puts "=> #{result}"
  end
  puts "finished indexing"
end

desc 'Build last_updated.json'
task :last_updated do
  require 'json'
  require 'time'

  last_updates = {}
  `git ls-files docs`.split("\n").each { |file|
    lang, name = file['docs/'.size..-1].split('/', 2)
    if name.nil?
      name = lang
      lang = 'en'
    end

    path = Pathname.new(file).realpath.to_s
    last_updates[lang] ||= {}
    last_updates[lang][File.basename(name, ".txt")] = Time.at((`git log --pretty=%ct --max-count=1 #{path}`.strip).to_i).utc
  }

  File.write("./config/last_updated.json", JSON.dump(last_updates))
end
