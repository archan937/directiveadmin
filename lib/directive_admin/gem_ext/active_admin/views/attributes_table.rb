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

    end
  end
end
