require File.expand_path('../../test_helper.rb', __FILE__)

class FluentdDocsTest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  docs_path = File.expand_path('../../docs', __FILE__)
  Dir.chdir(docs_path)
  Dir.glob(['*.txt', '*/*.txt']) do |url_part|
    # Skip macro files, which start with "_"
    if not url_part.split("/").last.start_with?("_")
      url_part.gsub!(/.txt$/, '')
      method_name = url_part.gsub(/[-\/]/, '_')
      define_method("test_#{method_name}".to_s) do
        if url_part.start_with?('ja/')
          get "/ja/articles/#{url_part.split("/", 2).last}"
        else
          get "/articles/#{url_part}"
        end
        assert last_response.ok?
      end
    end
  end

end