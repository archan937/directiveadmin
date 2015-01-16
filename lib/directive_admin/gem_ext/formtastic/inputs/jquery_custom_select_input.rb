module Formtastic
  module Inputs
    class JqueryCustomSelectInput < SelectInput
      include Base::JqueryDriven

    private

      def inputs_html
        options[:include_blank] ||= options[:placeholder]
        options[:group_by] ? grouped_select_html : select_html
      end

      def collection_from_options
        if (collection = options[:collection]).is_a?(Array) && collection.first.is_a?(String)
          Hash[collection.collect{|x| [x.humanize, x]}]
        else
          super
        end
      end

    end
  end
end
