module ActiveAdmin
  class BaseController < ::InheritedResources::Base
    module Authorization

    protected

      def authorized?(action, subject = nil, klass = nil, *args)
        arguments = [action, subject, klass].first(active_admin_authorization.method(:authorized?).arity.abs)
        active_admin_authorization.send :authorized?, *arguments, *args
      end

    end
  end
end
