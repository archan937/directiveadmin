module DirectiveAdmin
  class Engine < Rails::Engine

    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w(directive_admin/directive_admin.js directive_admin/directive_admin.css)
    end

  end
end
