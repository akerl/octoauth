Gem::Specification.new do |s|
  s.name        = 'octoauth'
  s.version     = '1.9.0'

  s.required_ruby_version = '>= 2.5.0'

  s.summary     = 'Auth token helper for GitHub API'
  s.description = 'Lightweight wrapper to sanely handle OAuth tokens with Octokit'
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/akerl/octoauth'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.test_files  = `git ls-files spec/*`.split

  s.add_dependency 'octokit', '~> 4.22.0'
  s.add_dependency 'userinput', '~> 1.0.2'

  s.add_development_dependency 'goodcop', '~> 0.9.5'
  s.add_development_dependency 'vcr', '~> 5.0.0'
  s.add_development_dependency 'webmock', '~> 3.7.6'

  s.metadata['rubygems_mfa_required'] = 'true'
end
