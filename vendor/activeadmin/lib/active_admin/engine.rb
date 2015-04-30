module ActiveAdmin
  class Engine < ::Rails::Engine
    initializer "active_admin.precompile", group: :all do |app|
      ActiveAdmin.application.all_stylesheets.each do |path, _|
        app.config.assets.precompile << path
      end
      ActiveAdmin.application.all_javascripts.each do |path|
        app.config.assets.precompile << path
      end
    end
  end
end
