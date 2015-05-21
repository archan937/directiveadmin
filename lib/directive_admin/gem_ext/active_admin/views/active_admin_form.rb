module ActiveAdmin
  module Views
    class ActiveAdminForm < FormtasticProxy

      def commit_action_with_cancel_link
        action(:submit)
        if (referer = request.referer) && ((url = URI(request.referer).path) != request.path)
          cancel_link url
        else
          cancel_link
        end
      end

    end
  end
end
