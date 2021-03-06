module ActiveAdmin
  class Namespace
    include AssetRegistration

    def javascripts
      (@javascripts ||= Set.new).merge(ActiveAdmin.application.javascripts)
      @javascripts
    end

    def stylesheets
      (@stylesheets ||= {}).merge!(ActiveAdmin.application.stylesheets)
      @stylesheets
    end

    def route_prefix
      if instance_variable_defined? :@route_prefix
        instance_variable_get :@route_prefix
      else
        read_default_setting :route_prefix
      end || name
    end

    def add_impersonable_users_to_menu(menu, current_user, actual_user)
      current_user.class.where("id != #{current_user.id}").each do |user|
        if actual_user.admin? || !user.admin?
          menu.add id: "impersonate_#{user.id}", label: ->{ display_name user }, url: "/impersonate/#{user.id}", parent: "current_user", html_options: {data: {no_turbolink: true}}
        end
      end
    end

  end
end
