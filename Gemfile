source 'https://rubygems.org'

gem "puppet",             "< 4"
gem "facter",             "< 3"
gem 'safe_yaml',          "~> 1.0.4"

# json_pure and json have been pinned to before version 2.0
# as versions have no support for ruby 1.9.3 and greater
gem 'json_pure', '< 2'
gem 'json',      '< 2'


group :test do
  gem 'puppet-lint'
  gem 'rspec-puppet', '~> 0.1.3'
  gem 'metadata-json-lint'
end

group :development, :test do
  gem 'rake'
  gem 'puppetlabs_spec_helper', '<0.8'
end
