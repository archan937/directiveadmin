module ActiveAdmin
  module Views
    class PaginatedCollection < ActiveAdmin::Component

      def build(collection, options = {})
        @collection     = collection.instance_variable_get(:@active_relation) || collection
        @param_name     = options.delete(:param_name)
        @download_links = options.delete(:download_links)
        @display_total  = options.delete(:pagination_total) { true }

        unless @collection.respond_to?(:num_pages)
          raise(StandardError, "Collection is not a paginated scope. Set collection.page(params[:page]).per(10) before calling :paginated_collection.")
        end

        @contents = div(class: "paginated_collection_contents")
        build_pagination_with_formats(options)
        @built = true
      end

    end
  end
end
