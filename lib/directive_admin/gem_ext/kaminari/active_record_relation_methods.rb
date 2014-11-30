module Kaminari
  module ActiveRecordRelationMethods

    def total_count(column_name = :all, options = {}) #:nodoc:
      @total_count ||= begin
        result = DirectiveAdmin.to_table_collection(self, exclude: [:limit, :offset, :group_by, :order_by]) do
          column "COUNT(DISTINCT id) AS total_count"
        end
        result[0]["total_count"]
      end
    end

  end
end
