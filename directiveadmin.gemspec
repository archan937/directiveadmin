# -*- encoding: utf-8 -*-
require File.expand_path("../lib/directive_admin/version", __FILE__)

Gem::Specification.new do |gem|
  gem.author        = "Paul Engel"
  gem.email         = "pm_engel@icloud.com"
  gem.summary       = %q{A layer on top of ActiveAdmin for adding more power and flexibility (opinionated customizations)}
  gem.description   = %q{A layer on top of ActiveAdmin for adding more power and flexibility (opinionated customizations)}
  gem.homepage      = "https://github.com/archan937/directiveadmin"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "directiveadmin"
  gem.require_paths = ["lib"]
  gem.version       = DirectiveAdmin::VERSION

  gem.add_dependency "arbre",               "~> 1.0", ">= 1.0.2"
  gem.add_dependency "bourbon"
  gem.add_dependency "coffee-rails"
  gem.add_dependency "formtastic",          "~> 3.1"
  gem.add_dependency "formtastic_i18n"
  gem.add_dependency "inherited_resources", "~> 1.4", "!= 1.5.0"
  gem.add_dependency "jquery-rails"
  gem.add_dependency "jquery-ui-rails",     "~> 5.0"
  gem.add_dependency "kaminari",            "~> 0.15"
  gem.add_dependency "rails",               ">= 3.2", "< 4.2"
  gem.add_dependency "ransack",             "~> 1.3"
  gem.add_dependency "sass-rails"

  # gem.add_dependency "activeadmin", ">= 1.0.0"
  gem.add_dependency "directiverecord", "0.1.8"
  gem.add_dependency "pundit", "0.3.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "yard"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "mocha"
end
