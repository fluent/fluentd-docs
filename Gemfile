source 'https://rubygems.org'

# https://devcenter.heroku.com/articles/ruby-versions
ruby '2.1.2'

gem 'sinatra', '1.3.3'
gem 'sinatra-assetpack', '0.2.8', :require => 'sinatra/assetpack'
gem 'rdiscount', '1.6.8'
gem 'rest-client', '1.2.0'
gem 'haml', '2.2.17'
gem 'coderay'
gem 'rack-codehighlighter'
gem 'sanitize'
gem 'jemalloc', '~> 0.1.8'

# Compressor
gem 'yui-compressor', :require => 'yui/compressor'

# Webserver
gem 'unicorn', '~> 4.2.1'
gem 'unicorn-worker-killer', '~> 0.2.0'

# Addons
gem 'newrelic_rpm', '~> 3.4.1'
gem 'indextank', '~> 1.0.12'
gem 'airbrake', '~> 3.1.5'

# Dev
group :development do
  gem 'rake'
  gem 'shotgun', '~> 0.9'
end

# Production
group :production do
  gem 'rack-cache', '~> 1.2'
  gem 'dalli', '~> 2.1.0'
end
