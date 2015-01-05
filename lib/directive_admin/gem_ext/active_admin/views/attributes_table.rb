module ActiveAdmin
  module Views
    class AttributesTable < ActiveAdmin::Component

      alias :original_row :row

      def row(*attrs, &block)
        attrs.select! do |attribute|
          authorized?(:row, attribute.to_s)
        end
        original_row *attrs, &block unless attrs.empty?
      end

      alias :original_content_for :content_for

      def content_for(record, attr)
        value = original_content_for(record, attr)
        if !value.blank? && (column = record.class.columns_hash[attr]) && !attr.match(/_id$/)
          if column.type == :integer
            return ActiveSupport::NumberHelper.number_to_currency Integer(value), :unit => "", :precision => 0
          elsif precision = column.scale
            return ActiveSupport::NumberHelper.number_to_currency Float(value), :unit => "", :precision => precision
          end
        end
        value
      end

    end
  end
end
