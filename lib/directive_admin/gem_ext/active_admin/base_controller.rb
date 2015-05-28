require "directive_admin/gem_ext/active_admin/base_controller/authorization"

module ActiveAdmin
  class BaseController < ::InheritedResources::Base

    helper_method :scope?

  protected

    def scope?(key, klass = resource_class)
      active_admin_authorization.send(:policy, klass, nil).class::Scope.new(send(ActiveAdmin.application.current_user_method), nil).scope?(key)
    end

  end
end
