Encoding.default_external = Encoding.default_internal = 'utf-8'

require 'rdiscount'
require 'sanitize'

class Article
  def text_only
    @body = @body.gsub(/\<[^\<]+\>/,'')
    self
  end
  
  def self.load(topic, source)
    topic = new(topic, source)
    topic.parse
    return topic
  end
  
  attr_reader :topic, :title, :desc, :content, :toc, :intro, :body
  
  def initialize(name, source)
    @topic = name
    @source = source
  end
  
  def parse
    @topic = topic
    @content = markdown(source)
    @title, @content = _title(@content)
    @desc = _desc(@content)
    @toc, @content = _toc(@content)
    if @toc.any?
      @intro, @body = @content.split('<h2>', 2)
      @body = "<h2>#{@body}"
    else
      @intro, @body = '', @content
    end
  end
  
  protected
  
  def source
    @source
  end
  
  def notes(source)
    source.gsub(
                /NOTE: (.*?)\n\n/m,
                "<table class='note'>\n<td class='icon'></td><td class='content'>\\1</td>\n</table>\n\n"
		)
  end
  
  def markdown(source)
    html = RDiscount.new(notes(source), :smart).to_html
    # parse custom {lang} definitions to support syntax highlighting
    html.gsub(/<pre><code>\{(\w+)\}/, '<pre><code class="brush: \1;">')
  end
  
  def topic_file(topic)
    if topic.include?('/')
      topic
    else
      "#{options.root}/docs/#{topic}.txt"
    end
  end

  def _title(content)
    title = content.match(/<h1>(.*)<\/h1>/)[1]
    content_minus_title = content.gsub(/<h1>.*<\/h1>/, '')
    return title, content_minus_title
  end

  def _desc(content)
    desc = Sanitize.clean(content.match(/<p>(.*)<\/p>/)[1])
    return desc
  end

  def slugify(title)
    title.downcase.gsub(/[^a-z0-9 -]/, '').gsub(/ /, '-')
  end

  def _toc(content)
    toc = content.scan(/<h2>([^<]+)<\/h2>/m).to_a.map { |m| m.first }
    content_with_anchors = content.gsub(/(<h2>[^<]+<\/h2>)/m) do |m|
      "<a name=\"#{slugify(m.gsub(/<[^>]+>/, ''))}\"></a>#{m}"
    end
    return toc, content_with_anchors
  end
end
