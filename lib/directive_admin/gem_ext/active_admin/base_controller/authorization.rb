module ActiveAdmin
  class BaseController < ::InheritedResources::Base
    module Authorization

    protected

      def authorized?(*args)
        active_admin_authorization.send :authorized?, *args
      end

    end
  end
end
