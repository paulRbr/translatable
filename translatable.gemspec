Gem::Specification.new do |s|
  s.name        = 'easy_translatable'
  s.version     = '0.1.6'
  s.date        = '2014-02-17'
  s.summary     = "Handle translations for AR models into a single table"
  s.description = "Handle translations for AR models into a single table. And provide a helper to select translated values."
  s.authors     = ["Paul Bonaud", "Charly Poly"]
  s.email       = 'paul.bonaud@clicrdv.com'
  s.files       = Dir['LICENSE', 'README.md', 'lib/**/*']
  s.add_runtime_dependency 'activesupport', '~> 3.2'
  s.add_development_dependency 'database_cleaner', '~> 0.6.0'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'pathname_local'
  s.add_development_dependency 'test_declarative'
  s.add_development_dependency 'friendly_id'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  if RUBY_VERSION >= "1.9"
     s.add_development_dependency 'coveralls', '~> 0'
  end
  s.homepage    = 'http://rubygems.org/gems/single_translatable'
  s.license       = 'MIT'
end