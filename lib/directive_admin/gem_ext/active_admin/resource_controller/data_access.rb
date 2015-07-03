module ActiveAdmin
  class ResourceController < BaseController
    module DataAccess

    protected

      # NOTE: Put `apply_filtering` before `apply_authorization_scope`
      def find_collection
        collection = scoped_collection
        collection = apply_filtering(collection)
        collection = apply_authorization_scope(collection)
        collection = apply_sorting(collection)
        collection = apply_scoping(collection)
        collection = apply_includes(collection)
        unless request.format == "text/csv"
          collection = apply_pagination(collection)
        end
        apply_collection_decorator(collection)
      end

    end
  end
end
