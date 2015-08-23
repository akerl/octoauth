Gem::Specification.new do |s|
  s.name        = 'octoauth'
  s.version     = '1.3.0'
  s.date        = Time.now.strftime("%Y-%m-%d")

  s.summary     = 'Auth token helper for GitHub API'
  s.description = "Lightweight wrapper to sanely handle OAuth tokens with Octokit"
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/akerl/octoauth'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.test_files  = `git ls-files spec/*`.split

  s.add_dependency 'octokit', '~> 4.1.0'
  s.add_dependency 'userinput', '~> 1.0.0'

  s.add_development_dependency 'rubocop', '~> 0.33.0'
  s.add_development_dependency 'rake', '~> 10.4.0'
  s.add_development_dependency 'coveralls', '~> 0.8.0'
  s.add_development_dependency 'rspec', '~> 3.3.0'
  s.add_development_dependency 'fuubar', '~> 2.0.0'
  s.add_development_dependency 'webmock', '~> 1.21.0'
  s.add_development_dependency 'vcr', '~> 2.9.2'
end
