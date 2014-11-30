module ActiveAdmin
  module BatchActions
    class ResourceSelectionCell < ActiveAdmin::Component

      def build(resource)
        id = resource.is_a?(Hash) ? resource.stringify_keys["id"] : resource.id
        input type: "checkbox", id: "batch_action_item_#{id}", value: id, class: "collection_selection", name: "collection_selection[]"
      end

    end
  end
end
