require File.expand_path('../../test_helper.rb', __FILE__)

class FluentdDocsTest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def setup
    $stdout = StringIO.new("")
  end

  def app
    Sinatra::Application
  end

  docs_path = File.expand_path('../../docs', __FILE__)
  
  # generate tests for the current stable versions and i18n for them
  Dir.glob("#{docs_path}/*.txt") do |url_part|
    url_part.gsub!(/^#{docs_path}\//, "")
    # Skip macro files, which start with "_"
    if not url_part.split("/").last.start_with?("_")
      url_part.gsub!(/.txt$/, '')
      method_name = url_part.gsub(/[-\/]/, '_')
      define_method("test_#{method_name}".to_s) do
        get "/articles/#{url_part.split("/", 2).last}"
        assert last_response.ok?
      end
    end
  end

  # generate tests for the new versions
  Dir.glob("#{docs_path}/v0.12/*.txt") do |url_part|
    url_part.gsub!(/^#{docs_path}\/v0.12\//, "")
    # Skip macro files, which start with "_"
    if not url_part.split("/").last.start_with?("_")
      url_part.gsub!(/.txt$/, '')
      method_name = url_part.gsub(/[-\/]/, '_')
      define_method("test_v0_12_#{method_name}".to_s) do
        get "/v0.12/articles/#{url_part.split("/", 2).last}"
        assert last_response.ok?
      end
    end    
  end
end
