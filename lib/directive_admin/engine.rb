module DirectiveAdmin
  class Engine < Rails::Engine

    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w(directive_admin/directive_admin.js directive_admin/directive_admin.css)
    end

    initializer "directive_admin.add_middleware" do |app|
      app.middleware.use DirectiveAdmin::Middleware
    end

  end
end
