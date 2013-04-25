require 'rubygems'
require 'sinatra'
require 'sinatra/assetpack'
require 'haml'
require 'sass'
require 'coderay'
require 'indextank'
require 'rack/codehighlighter'

$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'article.rb'
require 'term.rb'

# Airbrake
configure :production do
  require 'airbrake'
  Airbrake.configure do |config|
    config.api_key = `ENV['AIRBRAKE_API_KEY']`
  end
  use Airbrake::Rack
end

# NewRelic
configure :production do
  require 'newrelic_rpm'
end

# require 'rack/coderay'
# use Rack::Coderay, "//pre[@lang]>code"
use Rack::Codehighlighter, :coderay, :markdown => true, :element => "pre>code", :pattern => /\A:::(\w+)\s*(\n|&#x000A;)/i, :logging => false
configure :production do
  ENV['APP_ROOT'] ||= File.dirname(__FILE__)
end

set :app_file, __FILE__
set :static_cache_control, [:public, :max_age => 3600*24]

# In-Mem Cache
$IO_CACHE ||= {}
configure :production do
  if $IO_CACHE.empty?
    Dir.glob(["#{settings.root}/docs/*.txt", "#{settings.root}/docs/*/*.txt"]) { |path|
      $IO_CACHE[path] = File.read(path)
    }
  end
end

#
# For i18n
#
def build_available_languages
  articles = Dir.glob("#{settings.root}/docs/*.txt").map { |a|
    a["#{settings.root}/docs/".size..-(1 + ".txt".size)]
  }

  languages = {}
  articles.each { |article|
    langs = ['en']
    Dir.glob("#{settings.root}/docs/*/#{article}.txt").each { |a|
      langs << a["#{settings.root}/docs/".size..-(1 + 1 + "#{article}.txt".size)]
    }
    languages[article] = langs.sort
  }
  languages
end
$AVAILABLE_LANGUAGES = build_available_languages
$DEFAULT_LANGUAGE = 'en'

#
# NOT FOUND
#
not_found do
  erb :not_found
end

#
# Static Assets
# @see http://ricostacruz.com/sinatra-assetpack/
#
set :root, File.dirname(__FILE__)
Sinatra.register Sinatra::AssetPack
assets {
  serve '/js',  from: 'app/js'  # Optional
  serve '/css', from: 'app/css' # Optional
  js :app, '/js/app.js', [
    '/js/*.js'
  ]
  css :application, '/css/application.css', [
    '/css/*.css'
  ]
  js_compression :yui
  css_compression :yui
  prebuild true # only on production
  expires 24*3600*7, :public
}

#
# PATHS
#
get '/' do
  redirect '/articles/quickstart'
end

get '/robots.txt' do
  content_type 'text/plain'
  "User-agent: *\nSitemap: /sitemap.xml\n"
end

get '/sitemap.xml' do
  @articles = []
  sections.each { |_, _, categories|
    categories.each { |_, _, articles|
      articles.each { |name, _, _|
        @articles << name
      }
    }
  }
  content_type 'text/xml'
  erb :sitemap, :layout => false
end

get '/search' do
  page = params[:page].to_i
  search, prev_page, next_page = search_for(params[:q], page)
  erb :search, :locals => {:search => search, :query => params[:q], :prev_page => prev_page, :next_page => next_page}
end

get '/categories/:category' do
  cache_long
  render_category params[:category]
end

get '/:lang/categories/:category' do
  cache_long
  render_category params[:category], params[:lang]
end

get '/articles/:article' do
  puts "@[#{ENV['RACK_ENV']}.articles] #{{ :name => params[:article] }.to_json}"
  cache_long
  render_article params[:article], params[:congrats]
end

get '/:lang/articles/:article' do
  puts "@[#{ENV['RACK_ENV']}.articles] #{{ :name => params[:article] }.to_json}"
  cache_long
  render_article params[:article], params[:congrats], params[:lang]
end

helpers do
  def render_category(category, lang = nil)
    @articles = []
    @desc = ''
    sections.each { |_, _, categories|
      categories.each { |name, title, articles|
        if name == category
          @title = title
          @articles = articles
          @desc = title
          break
        end
      }
    }
    if @articles.length == 1
      article_name = @articles.first.first
      redirect "/articles/#{article_name}"
    elsif !@articles.empty?
      erb :category
    else
      status 404
    end
  rescue Errno::ENOENT
    status 404
  end

  def render_article(article, congrats, lang = $DEFAULT_LANGUAGE)
    status 404 unless avaiable_language?(article, lang)

    @filepath = article_file(article, lang)
    unless $IO_CACHE.has_key? @filepath
      $IO_CACHE[@filepath] = File.read(@filepath)
    end
    @article = Article.load(article, $IO_CACHE[@filepath])

    @title   = @article.title
    @desc    = @article.desc
    @content = @article.content
    @intro   = @article.intro
    @toc     = @article.toc
    @body    = @article.body
    @congrats = congrats ? true : false
    @current_lang = lang
    @available_langs = $AVAILABLE_LANGUAGES[article]

    erb :article
  rescue Errno::ENOENT
    status 404
  end

  def article_file(article, lang)
    if article.include?('/')
      article
    else
      if lang == $DEFAULT_LANGUAGE
        "#{settings.root}/docs/#{article}.txt"
      else
        "#{settings.root}/docs/#{lang}/#{article}.txt"
      end
    end
  end

  def avaiable_language?(article, lang)
    return true if lang == $DEFAULT_LANGUAGE

    $AVAILABLE_LANGUAGES[article].include?(lang)
  end

  def cache_long
    response['Cache-Control'] = "public, max-age=#{60 * 60}" unless development?
  end

  def slugify(title)
    title.downcase.gsub(/[^a-z0-9 -]/, '').gsub(/ /, '-')
  end

  def find_category(article)
    return nil if article.nil?
    sections.each { |_, _, categories|
      categories.each { |category_name, _, articles|
        articles.each { |article_name, _, _|
          return category_name if article_name == article
        }
      }
    }
    nil
  end

  def find_keywords(article, category)
    default = ['Fluentd', 'log collector']
    sections.each { |_, _, categories|
      categories.each { |category_name, _, articles|
        return default + [category_name] if category_name == category
        articles.each { |article_name, title, keywords|
          if article_name == article
            return default + [title] + keywords
          end
        }
      }
    }
    default
  end

  def sections
    TOC.sections
  end

  def next_section(current_slug, root=sections)
    nil
  end

  def search_for(query, page = 0)
    client = IndexTank::Client.new(ENV['SEARCHIFY_API_URL'])
    index = client.indexes('td-docs')
    search = index.search(query, :start => page * 10, :len => 10, :fetch => 'title', :snippet => 'text')
    next_page =
        if search['matches'] > (page + 1) * 10
          page + 1
        end
    prev_page =
        if page > 0
          page - 1
        end
    [search, prev_page, next_page]
  end

  alias_method :h, :escape_html
end

module TOC
  extend self

  def sections
    @sections ||= []
  end

  # define a section
  def section(name, title)
    sections << [name, title, []]
    yield if block_given?
  end

  # define a category
  def category(name, title)
    sections.last.last << [name, title, []]
    yield if block_given?
  end

  # define a article
  def article(name, title, keywords=[])
    keywords = [name] + keywords
    sections.last.last.last.last << [name, title, keywords]
  end

  file = File.dirname(__FILE__) + '/lib/toc.rb'
  eval File.read(file), binding, file
end
