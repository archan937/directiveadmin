module Formtastic
  module Inputs
    class SelectInput

      def collection
        super.sort{|a, b| a[0] <=> b[0]}
      end

    end
  end
end
