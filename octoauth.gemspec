Gem::Specification.new do |s|
  s.name        = 'octoauth'
  s.version     = '0.0.6'
  s.date        = Time.now.strftime("%Y-%m-%d")

  s.summary     = ''
  s.description = ""
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/akerl/octoauth'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.test_files  = `git ls-files spec/*`.split

  s.add_dependency 'octokit', '~> 3.1.0'
  s.add_dependency 'userinput', '~> 0.0.2'

  s.add_development_dependency 'rubocop', '~> 0.23.0'
  s.add_development_dependency 'rake', '~> 10.3.0'
  s.add_development_dependency 'coveralls', '~> 0.7.0'
  s.add_development_dependency 'rspec', '~> 3.0.0'
  s.add_development_dependency 'fuubar', '~> 1.3.3'
  s.add_development_dependency 'webmock', '~> 1.18.0'
end
