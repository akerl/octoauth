Gem::Specification.new do |s|
  s.name        = 'octoauth'
  s.version     = '1.5.6'
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.summary     = 'Auth token helper for GitHub API'
  s.description = 'Lightweight wrapper to sanely handle OAuth tokens with Octokit' # rubocop:disable Metrics/LineLength
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/akerl/octoauth'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.test_files  = `git ls-files spec/*`.split

  s.add_dependency 'octokit', '~> 4.14.0'
  s.add_dependency 'userinput', '~> 1.0.0'

  s.add_development_dependency 'codecov', '~> 0.1.1'
  s.add_development_dependency 'fuubar', '~> 2.4.1'
  s.add_development_dependency 'goodcop', '~> 0.7.1'
  s.add_development_dependency 'rake', '~> 12.3.0'
  s.add_development_dependency 'rspec', '~> 3.8.0'
  s.add_development_dependency 'rubocop', '~> 0.72.0'
  s.add_development_dependency 'vcr', '~> 5.0.0'
  s.add_development_dependency 'webmock', '~> 3.6.0'
end
