require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter '/spec/'
end

require 'rspec'
require 'octoauth'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
