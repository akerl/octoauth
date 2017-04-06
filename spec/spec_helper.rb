if ENV['CI'] == 'true'
  require 'simplecov'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'rspec'
require 'octoauth'

require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('<USER>') { ENV['OCTOAUTH_LOGIN'] || 'user' }
  c.filter_sensitive_data('<PASSWORD>') { ENV['OCTOAUTH_PASSWORD'] || 'pw' }
  c.before_record do |i|
    %w[Authorization X-GitHub-OTP].each do |header|
      i.request.headers.delete header
    end
    %w[Etag X-Github-Request-Id X-Served-By].each do |header|
      i.response.headers.delete header
    end
  end
end
