class TOC

  attr_reader :base_directory
  
  def initialize(base_directory, lang, ver)
    @base_directory = base_directory
    file = "#{File.dirname(__FILE__)}/toc.#{lang}.#{ver}.rb"
    eval(File.read(file), binding, file)
  end

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
end
