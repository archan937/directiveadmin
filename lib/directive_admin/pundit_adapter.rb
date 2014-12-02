module DirectiveAdmin
  class PunditAdapter < ActiveAdmin::AuthorizationAdapter
    include Pundit

    def authorized?(action, subject = nil, klass = nil, *args)
      policy(subject || resource, klass).send :"#{action}?", *args
    end

    def scope_collection(collection, action_name = nil)
      policy_scope(collection)
    end

  private

    alias :pundit_user :user

    def policy(subject, klass)
      klass = klass.name if klass
      klass ||= begin
        case subject
        when String, Hash
          resource.resource_class.name rescue resource.menu_item.id.camelize
        when ActiveAdmin::Page
          subject.menu_item.id.camelize
        when Class
          subject.name
        else
          subject.class.name
        end
      end
      klass = (policies[klass] ||= (klass.constantize.policy_class rescue "#{klass}Policy".constantize)) if klass.is_a?(String)
      klass.new pundit_user, subject
    end

  end
end
