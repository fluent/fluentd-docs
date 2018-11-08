require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'coderay'
require 'rack/codehighlighter'
require 'json'
require 'time'

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

$DEFAULT_LANGUAGE = 'en'
$DEFAULT_VERSION = 'v1.0'
$DEPRECATED_VERSIONS = ['v0.10']
$ALL_VERSIONS = ['v1.0', 'v0.14', 'v0.12']
$TD_AGENT_VERSIONS = {'v1.0' => 'td-agent3', 'v0.12' => 'td-agent2'}

#
# For table-of-content
#
require 'toc'

def build_tocs
  toc_vers = Dir.glob("#{settings.root}/lib/toc.#{$DEFAULT_LANGUAGE}.*.rb").map { |toc|
    File.basename(toc, ".rb")["toc.#{$DEFAULT_LANGUAGE}.".size..-1]
  }

  tocs = {}
  toc_vers.each { |ver|
    tocs[ver] = TOC.new(settings.root, $DEFAULT_LANGUAGE, ver)
  }
  tocs
end
$TOCS = build_tocs

#
# Last update list for each article
#
$LAST_UPDATED = JSON.parse(File.read("#{settings.root}/config/last_updated.json"))

#
# NOT FOUND
#
not_found do
  erb :not_found
end

set :root, File.dirname(__FILE__)

# sinatra-asset-pipeline
unless ENV['RACK_ENV'] == 'test'
  require 'sinatra/asset_pipeline'
  set :assets_precompile, %w(application.js application.css *.png *.jpg *.svg *.eot *.ttf *.woff *.woff2)
  set :assets_paths, %w(/app/js/ /app/css/)
  set :assets_css_compressor, :yui
  set :assets_js_compressor, :yui
  register Sinatra::AssetPipeline
end

#
# PATHS
#
get '/' do
  redirect '/articles/quickstart', 301
end

get '/robots.txt' do
  content_type 'text/plain'
  "User-agent: *\nSitemap: /sitemap.xml\n"
end

get '/sitemap.xml' do
  @article_names = []
  $ALL_VERSIONS.each { |version|
    $TOCS[version].sections.each { |_, _, categories|
      categories.each { |_, _, articles|
        articles.each { |name, _, _|
          @article_names << [version, name]
        }
      }
    }
  }
  content_type 'text/xml'
  erb :sitemap, :layout => false
end

get '/categories/:category' do
  @category_name = params[:category]
  redirect "/#{$DEFAULT_VERSION}/categories/#{@category_name}", 301
end

get %r{/(v\d+\.\d+)/categories/(\S+)} do |version, category|
  @version_num = @article_name = @category_name = @query_string = nil
  @version_num = version
  @version_num = 'v1.0' if version == 'v0.14'
  @category_name = category
  cache_long
  render_category category, version
end

get '/articles/:article' do
  @article_name = params[:article]
  redirect "/#{$DEFAULT_VERSION}/articles/#{@article_name}", 301
end

get %r{/(v\d+\.\d+)/articles/(\S+)} do |version, article|
  case article
  when 'users'
    redirect 'https://www.fluentd.org/testimonials'
  when 'architecture'
    redirect 'https://www.fluentd.org/architecture'
  else
    @version_num = @article_name = @category_name = @query_string = nil
    @version_num = version
    @version_num = 'v1.0' if version == 'v0.14'
    @article_name = article
    puts "@[#{ENV['RACK_ENV']}.articles] #{{ name: article }.to_json}"
    cache_long
    render_article article, version
  end
end

helpers do
  def link_to(page)
    "/#{@article_version}" + page
  end

  def render_category(category, ver)
    @article_version = ver

    @articles = []
    @desc = ''
    sections(ver).each { |_, _, categories|
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
      redirect "/#{ver}/articles/#{article_name}", 301
    elsif !@articles.empty?
      @articles
      erb :category
    else
      status 404
    end
  rescue Errno::ENOENT
    status 404
  end

  def render_article(article, ver)
    @default_url = "/#{$DEFAULT_VERSION}/articles/#{article}"
    @filepath = article_file(article, ver)
    @has_default_version = File.exist?(article_file(article, $DEFAULT_VERSION))

    begin
      unless $IO_CACHE.has_key? @filepath
        $IO_CACHE[@filepath] = File.read(@filepath)
      end
    rescue Errno::ENOENT
      if ver != $DEFAULT_VERSION && @has_default_version
        return redirect(@default_url, 301)
      else
        return status(404)
      end
    end

    doc_path = File.dirname(@filepath)

    @article = Article.load(article, $IO_CACHE[@filepath], doc_path, ver)
    @title   = @article.title
    @desc    = @article.desc
    @content = @article.content
    @intro   = @article.intro
    @toc     = @article.toc
    @body    = @article.body
    @available_versions = $ALL_VERSIONS
    @current_version = $DEFAULT_VERSION
    @article_version = ver
    @deprecated_article_version = $DEPRECATED_VERSIONS.include?(@article_version)
    @last_updated = ($LAST_UPDATED[ver] || {})[article] || Time.now.to_s

    erb :article
  end

  def article_file(article, ver)
    if article.include?('/')
      article
    else
      "#{settings.root}/docs/#{ver}/#{article}.txt"
    end
  end

  def article_file_exists?(article, ver)
    File.exist?(article_file(article, ver))
  end

  def cache_long
    response['Cache-Control'] = "public, max-age=#{60 * 60 * 6}" unless self.class.development?
  end

  def slugify(title)
    title.downcase.gsub(/[^a-z0-9 -_]/, '').gsub(/ /, '-')
  end

  def find_category(article, ver)
    return nil if article.nil?
    sections(ver).each { |_, _, categories|
      categories.each { |category_name, _, articles|
        articles.each { |article_name, _, _|
          return category_name if article_name == article
        }
      }
    }
    nil
  end

  def sections(ver)
    $TOCS[ver].sections
  end

  def next_section(current_slug, root=sections($DEFAULT_VERSION))
    nil
  end

  alias_method :h, :escape_html
end
