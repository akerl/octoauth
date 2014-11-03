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

module WebMock
  ##
  # Patch WebMock to allow Structs as response bodies
  class Response
    def assert_valid_body!
      true
    end
  end
end
