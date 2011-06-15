# encoding: utf-8

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "backstack"
  gem.homepage = "http://github.com/kswope/backstack"
  gem.license = "MIT"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "git-kevdev@snkmail.com"
  gem.authors = ["Kevin Swope"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

task :default => :test
task :test => [:test_neutral, :test_rails]

require 'rake/testtask'
Rake::TestTask.new(:test_neutral) do |test|
  test.libs << 'lib' << 'test/neutral'
  test.pattern = 'test/neutral/**/test_*.rb'
  test.verbose = true
end

# Bundler.setup (above) sets this and ruins rail's chance for loading
# properly in the test below.  Somebody tell me why a gem is setting
# ENV variables.
ENV['BUNDLE_GEMFILE'] = nil

desc "Run tests in rails root"
rails_root = "test/rails_root"
command = "rake"
task :test_rails do |t|
  chdir rails_root do
    puts "*** descending into #{rails_root} and running '#{command}'"
    system command
  end
end

