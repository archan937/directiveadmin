module ActiveAdmin
  module Helpers
    module Collection

      def collection_size(c = collection)
        unless c.is_a?(Array)
          if c.qry_options.include?(:offset)
            c = DirectiveAdmin.to_table_collection(c, exclude: [:group_by, :order_by]) do
              column "id"
            end
          else
            result = DirectiveAdmin.to_table_collection(c, exclude: [:group_by, :order_by]) do
              column "COUNT(id) AS collection_size"
            end
            return result[0]["collection_size"]
          end
        end
        c.size
      end

    end
  end
end
