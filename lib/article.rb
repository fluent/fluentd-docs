Encoding.default_external = Encoding.default_internal = 'utf-8'

require 'rdiscount'
require 'sanitize'
require 'strscan'

class Article
  def text_only
    @body = @body.gsub(/\<[^\<]+\>/,'')
    self
  end

  def self.load(topic, source, prefix, specified_document_version)
    topic = new(topic, source, prefix)
    topic.specified_document_version = specified_document_version
    topic.parse
    return topic
  end

  attr_reader :topic, :title, :desc, :content, :toc, :intro, :body
  attr_accessor :specified_document_version

  def initialize(name, source, prefix)
    @topic = name
    @source = source
    @prefix = prefix
    @specified_document_version = nil
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

  def rewrite_link(source)
    # LINK(v0.14):[link text](/path/to/page) => <a href="/v0.14/path/to/page">link text</a>
    # LINK:[link text](/path/to/page)
    #    when current path without version prefix      => <a href="/path/to/page">link text</a>
    #    when current path with version prefix (v0.12) => <a href="/v0.12/path/to/page">link text</a>
    source.gsub(/LINK(?:\((v\d+\.\d+)\))?:\[([^\]]+?)\]\(([^\)]+?)\)/) do
      link_doc_version = $1
      link_text = $2
      raw_path = $3
      link_path = if link_doc_version
                    "/#{link_doc_version}/#{raw_path}"
                  else
                    raw_path
                  end
      "<a href=\"#{link_path}\">#{link_text}</a>"
    end
  end

  def notes(source)
    source.gsub(
                /NOTE: (.*?)\n\n/m,
                "<table class='note'>\n<td class='icon'></td><td class='content'>\\1</td>\n</table>\n\n"
		)
  end

  def includes(source)
    source.gsub(/INCLUDE: (.*?)\n\n/m) { |pattern|
      includes(File.read("#{@prefix}/#{$1}.txt")) + "\n\n"
    }
  end

  def markdown(source)
    html = RDiscount.new(notes(includes(rewrite_link(source))), :smart).to_html
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

  H2_RE = /<h2>([^<]+)<\/h2>/m
  H3_RE = /<h3>([^<]+)<\/h3>/m

  def _toc(content)
    toc = _scan_toc(content)
    content = content.gsub(H2_RE) { |m|
      "<a name=\"#{slugify(m.gsub(/<[^>]+>/, ''))}\"></a>#{m}"
    }
    content = content.gsub(H3_RE) { |m|
      "<a name=\"#{slugify(m.gsub(/<[^>]+>/, ''))}\"></a>#{m}"
    }
    return toc, content
  end

  def _scan_toc(content)
    ss = StringScanner.new(content)
    tocs = {}
    post_match = nil
    while matched = ss.scan_until(H2_RE)
      section = ss.matched.scan(H2_RE).first.first
      cur_pos = ss.charpos
      post_match = ss.post_match
      ss.check_until(H2_RE)
      tocs[section] = _scan_sub_toc(ss.pre_match ? ss.pre_match[cur_pos..-1] : post_match)
    end
    tocs
  end

  def _scan_sub_toc(content)
    ss = StringScanner.new(content)
    toc = []
    while matched = ss.scan_until(H3_RE)
      toc << ss.matched.scan(H3_RE).first.first
    end
    toc
  end

  def _toc_(content)
    toc = content.scan(/<h2>([^<]+)<\/h2>/m).to_a.map { |m| m.first }
    content_with_anchors = content.gsub(/(<h2>[^<]+<\/h2>)/m) do |m|
      "<a name=\"#{slugify(m.gsub(/<[^>]+>/, ''))}\"></a>#{m}"
    end
    return toc, content_with_anchors
  end
end
