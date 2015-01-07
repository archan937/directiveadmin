module DirectiveAdmin
  class Middleware

    def initialize(app)
      @app = app
    end

    def call(env)
      if current_user_method = ActiveAdmin.application.current_user_method
        user_scope = current_user_method.to_s.gsub("current_", "").to_sym

        if env["PATH_INFO"].match(/^\/impersonate\/(\d+)/)
          impersonated_user_id = $1.to_i
          actual_user = env["warden"].authenticate(:scope => user_scope)

          if !actual_user || (impersonated_user_id == actual_user.id)
            impersonated_user_id = nil
          end

          env["rack.session"][:"impersonated_#{user_scope}_id"] = impersonated_user_id

          return [302, {"Location" => (Rack::Request.new(env).referrer || "/#{DirectiveAdmin.namespace.name}")}, ["Moved Temporarily"]]
        end
      end
      @app.call env
    end

  end
end
