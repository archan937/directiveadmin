module ActiveAdmin
  class BaseController < ::InheritedResources::Base
    module Authorization

    protected

      def authorized?(*args)
        args = args.first(2) unless active_admin_authorization.is_a?(DirectiveAdmin::AuthorizationAdapter)
        active_admin_authorization.send :authorized?, *args
      end

    end
  end
end
