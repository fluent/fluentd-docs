class TOC
  def initialize(lang)
    file = "#{File.dirname(__FILE__)}/toc.#{lang}.rb"
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
