module ActiveAdmin
  module Comments
    module ShowPageHelper

      def active_admin_comments(*args, &block)
        active_admin_comments_for(resource, *args, &block) if authorized?(:read, ActiveAdmin::Comment)
      end

    end
  end
end
