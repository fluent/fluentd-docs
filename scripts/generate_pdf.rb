# = Environment
# OS: Mac OS X.
# GHC: The Glorious Glasgow Haskell Compilation System, version 7.6.3
# Pandoc: 1.11.1
# Tex: BasicTex 08 July 2012
#
# = Install
#
# pandoc:
#   https://gist.github.com/repeatedly/5747244
#
# gimli (currently not used):
#   % brew install wkhtmltopdf
#   % gem install gimli
#
# = How to use (root of fluentd-docs)
#   % ruby scripts/generate_pdf.rb
#
# Currently we use Pandoc because Pandoc support internal link and almost markdown syntax.
# But Pandoc's code highlight is poor, so we need more rich code highlight like gimli.

require 'fileutils'
require 'ostruct'

def settings
  os = OpenStruct.new
  os.root = '.'
  os
end

DOC_HOME = File.expand_path(Dir.pwd)

require "#{DOC_HOME}/lib/toc"

TMP_DIR = "#{DOC_HOME}/.tmp_docs"
ALL_TXT = "#{TMP_DIR}/all_txt.md"

Dir.mkdir(TMP_DIR) unless File.exist?(TMP_DIR)

def generate_image(path, resize = false)
  if path.start_with?('/')
    path = "./public#{path}"
  else
    # latex can't deal http so download file before
    save_path = "#{TMP_DIR}/#{File.basename(path)}"
    `wget -P #{TMP_DIR} #{path}` unless File.exist?(save_path)
    path = save_path
  end

  # latex can't convert gif file so convert to png before.
  if path.end_with?('.gif')
    `sips -s format png #{path} --out #{TMP_DIR}`
    path = "#{TMP_DIR}/#{File.basename(path)}"
    path[-3..-1] = 'png'
  end

  if resize
    path, src_path = "#{TMP_DIR}/#{File.basename(path)}", path
    FileUtils.cp(src_path, path) unless path == src_path
    `sips -Z 100 #{path}`
  end

  path
end

def fix_internal_link(line)
  line.gsub(/\[(.*?)\]\((.*?)\)/) { |match| 
    if $2.start_with?('http:') or $2.start_with?('https:')
      match
    else
      # Pandoc doesn't support [foo](bar#baz) style link but
      # this link format is used in table of content in HTML rendering.
      # So remove after # string from link.
      link = $2
      link = if index = link.index('#')
               link[0...index]
             else
               link
             end
      "[#{$1}](##{link})"
    end
  }
end

def parse_include(df, f)
  in_block = false # check current line is in code block or not
  f.each_line.with_index { |line, i|
    block = line.strip
    if match = /^.*\<img.*src="(.*?)" .*\>/.match(block)
      # User logos are different size, so we should resize these images.
      path = generate_image(match[1], name == 'users')
      df.puts("![](#{path})")
      next
    elsif block.start_with?(':::')
      # Wrap source code with '```' for Pandoc highlight.
      # If need more complex configuration, then switch '```' to '~~~~{.lang}'
      # TODO: We need code block folding.
      type = block[3..-1]
      type = 'text' if (type == 'term') || (type == 'text')
      type = 'javascript' if type == 'js'

      df.puts('')
      df.puts("```#{type}")
      in_block = true
      next
    elsif line.start_with?('INCLUDE: ')
      parse_include(df, File.read("#{DOC_HOME}/docs/#{line['INCLUDE: '.length..-1].strip}.txt"))
      next
    elsif in_block && !line.empty? && line[0] != " " && line[0] != "\n"
      df.puts('```')
      df.puts
      in_block = false
    end
    line = fix_internal_link(line)

    # 4 space is not needed when use code highlight
    df.puts(in_block ? line[4..-1] : line)
  }
  df.puts("```") if in_block
  df.puts
end

excludes = ['support', 'slides', 'logo']
exclude_categories = ['recipes']  # reduce duplicate document

# Pandoc's internal link can't link to arbitary section in another file.
# So, merge all files into one file.
File.open(ALL_TXT, 'w+') { |df|
  `wget -P #{TMP_DIR} https://raw.github.com/fluent/website/master/logos/fluentd.png` unless File.exist?("#{TMP_DIR}/fluentd.png")

  # Pandoc's cover notation
  df.puts(<<HEADER
% **Fluentd User Manual**
% ![](#{TMP_DIR}/fluentd.png)
% \\newpage

\\newpage

HEADER
)

  TOC.new('en').sections.each { |_, __, categories|
    categories.each { |_, __, articles|
      next if exclude_categories.include?(_)

      articles.each { |name, title, keywords|
        next if excludes.include?(name)

        f = File.read("#{DOC_HOME}/docs/#{name}.txt")
        in_block = false # check current line is in code block or not
        f.each_line.with_index { |line, i|
          block = line.strip
          if block.start_with?('rewriterule1 message ')
            line = '      rewriterule1 message ^\\[(\\\\w+)\\] \$1.\${tag}'
            block = line.strip
          end
          if i.zero?
            line = "#{block} {##{name}}"
          elsif match = /^.*\<img.*src="(.*?)" .*\>/.match(block)
            # User logos are different size, so we should resize these images.
            path = generate_image(match[1], name == 'users')
            df.puts("![](#{path})")
            next
          elsif block.start_with?(':::')
            # Wrap source code with '```' for Pandoc highlight.
            # If need more complex configuration, then switch '```' to '~~~~{.lang}'
            # TODO: We need code block folding.
            type = block[3..-1]
            type = 'text' if (type == 'term') || (type == 'text')
            type = 'javascript' if type == 'js'

            df.puts('')
            df.puts("```#{type}")
            in_block = true
            next
          elsif line.start_with?('INCLUDE: ')
            parse_include(df, File.read("#{DOC_HOME}/docs/#{line['INCLUDE: '.length..-1].strip}.txt"))
            next
          elsif in_block && !line.empty? && line[0] != " " && line[0] != "\n"
            df.puts('```')
            df.puts
            in_block = false
          end
          line = fix_internal_link(line)

          # 4 space is not needed when use code highlight
          df.puts(in_block ? line[4..-1] : line)
        }
        df.puts("```") if in_block
        df.puts
      }
    }
  }
}

`pandoc -f markdown #{ALL_TXT} --latex-engine=xelatex -V geometry:margin=1in --toc -s -o #{DOC_HOME}/fluentd-docs.pdf`
