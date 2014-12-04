module ActiveAdmin
  module ViewHelpers
    module AutoLinkHelper

      def auto_url_for(resource)
        if config = active_admin_resource_for(resource.class)
          url_for config.route_instance_path resource if config.controller.action_methods.include?("show")
        end
      end

    end
  end
end
