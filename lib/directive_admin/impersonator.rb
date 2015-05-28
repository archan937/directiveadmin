module DirectiveAdmin
  module Impersonator
    extend ActiveSupport::Concern

    included do
      current_user_method = ActiveAdmin.application.current_user_method
      actual_user_method = current_user_method.to_s.gsub("current", "actual").to_sym

      user_scope = current_user_method.to_s.gsub("current_", "").to_sym
      session_key = :"impersonated_#{user_scope}_id"
      variable_name = :"@impersonated_#{user_scope}"

      alias_method actual_user_method, current_user_method
      helper_method actual_user_method

      define_method current_user_method do
        unless instance_variables.include?(variable_name)
          current_user = actual_user = send(actual_user_method)
          if impersonated_user_id = session[session_key]
            impersonated_user = actual_user.class.find impersonated_user_id
          end
          if actual_user && impersonated_user && UserPolicy.new(actual_user, nil).impersonate? && (actual_user.admin? || !impersonated_user.admin?)
            current_user = impersonated_user
          end
          instance_variable_set(variable_name, current_user)
        end
        instance_variable_get(variable_name)
      end
    end

  end
end
