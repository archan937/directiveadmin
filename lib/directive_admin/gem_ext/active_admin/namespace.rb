module ActiveAdmin
  class Namespace

    def add_impersonable_users_to_menu(menu, current_user)
      (current_user.class.where("id != #{current_user.id}")).each do |user|
        menu.add id: "impersonate_#{user.id}", label: ->{ display_name user }, url: "/impersonate/#{user.id}", parent: "current_user", html_options: {data: {no_turbolink: true}}
      end
    end

  end
end
