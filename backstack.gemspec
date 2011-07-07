# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{backstack}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kevin Swope"]
  s.date = %q{2011-07-07}
  s.description = %q{Rails plugin used to dynamically and intelligently generate "back" links or a breadcrumb trail.}
  s.email = %q{git-kevdev@snkmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "art/bowling_pins.graffle",
    "backstack.gemspec",
    "lib/backstack.rb",
    "lib/backstacklib.rb",
    "test/neutral/helper.rb",
    "test/neutral/test_backstacklib.rb",
    "test/rails_root/.gitignore",
    "test/rails_root/Gemfile",
    "test/rails_root/Gemfile.lock",
    "test/rails_root/README",
    "test/rails_root/Rakefile",
    "test/rails_root/app/controllers/application_controller.rb",
    "test/rails_root/app/controllers/c1_controller.rb",
    "test/rails_root/app/controllers/c2_controller.rb",
    "test/rails_root/app/controllers/c3_controller.rb",
    "test/rails_root/app/controllers/c4_controller.rb",
    "test/rails_root/app/helpers/application_helper.rb",
    "test/rails_root/app/helpers/c1_helper.rb",
    "test/rails_root/app/helpers/c2_helper.rb",
    "test/rails_root/app/helpers/c3_helper.rb",
    "test/rails_root/app/helpers/c4_helper.rb",
    "test/rails_root/app/views/c1/a.html.erb",
    "test/rails_root/app/views/c2/b.html.erb",
    "test/rails_root/app/views/c2/c.html.erb",
    "test/rails_root/app/views/c3/d.html.erb",
    "test/rails_root/app/views/c3/e.html.erb",
    "test/rails_root/app/views/c3/f.html.erb",
    "test/rails_root/app/views/c4/g.html.erb",
    "test/rails_root/app/views/c4/h.html.erb",
    "test/rails_root/app/views/c4/i.html.erb",
    "test/rails_root/app/views/c4/j.html.erb",
    "test/rails_root/app/views/layouts/_pins.html.erb",
    "test/rails_root/app/views/layouts/application.html.erb",
    "test/rails_root/config.ru",
    "test/rails_root/config/application.rb",
    "test/rails_root/config/boot.rb",
    "test/rails_root/config/environment.rb",
    "test/rails_root/config/environments/development.rb",
    "test/rails_root/config/environments/production.rb",
    "test/rails_root/config/environments/test.rb",
    "test/rails_root/config/initializers/backtrace_silencers.rb",
    "test/rails_root/config/initializers/inflections.rb",
    "test/rails_root/config/initializers/mime_types.rb",
    "test/rails_root/config/initializers/secret_token.rb",
    "test/rails_root/config/initializers/session_store.rb",
    "test/rails_root/config/locales/en.yml",
    "test/rails_root/config/routes.rb",
    "test/rails_root/db/seeds.rb",
    "test/rails_root/lib/tasks/.gitkeep",
    "test/rails_root/public/404.html",
    "test/rails_root/public/422.html",
    "test/rails_root/public/500.html",
    "test/rails_root/public/favicon.ico",
    "test/rails_root/public/images/rails.png",
    "test/rails_root/public/javascripts/.gitkeep",
    "test/rails_root/public/javascripts/application.js",
    "test/rails_root/public/robots.txt",
    "test/rails_root/public/stylesheets/.gitkeep",
    "test/rails_root/public/stylesheets/application.css",
    "test/rails_root/script/rails",
    "test/rails_root/test/functional/c1_controller_test.rb",
    "test/rails_root/test/functional/c2_controller_test.rb",
    "test/rails_root/test/functional/c3_controller_test.rb",
    "test/rails_root/test/functional/c4_controller_test.rb",
    "test/rails_root/test/integration/backstack_test.rb",
    "test/rails_root/test/performance/browsing_test.rb",
    "test/rails_root/test/test_helper.rb",
    "test/rails_root/test/unit/helpers/c1_helper_test.rb",
    "test/rails_root/test/unit/helpers/c2_helper_test.rb",
    "test/rails_root/test/unit/helpers/c3_helper_test.rb",
    "test/rails_root/test/unit/helpers/c4_helper_test.rb",
    "test/rails_root/vendor/plugins/.gitkeep"
  ]
  s.homepage = %q{http://github.com/kswope/backstack}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Rails plugin used to generate "back" links or a breadcrumb trail.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.0"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.0"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.0"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

