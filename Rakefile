require 'rake/testtask'

Rake::TestTask.new do |t|
		  
  if RUBY_VERSION >= "1.9.2"
     require 'simplecov'
     require 'coveralls'

     SimpleCov.formatter = Coveralls::SimpleCov::Formatter
     SimpleCov.start do
       add_group "Gem", 'lib/'
     end
  end
  t.libs << 'test'
end

desc "Run tests"
task :default => :test