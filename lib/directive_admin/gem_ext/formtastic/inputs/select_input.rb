module Formtastic
  module Inputs
    class SelectInput

      def collection
        super.sort{|a, b| a[0].to_s.strip <=> b[0].to_s.strip}
      end

    end
  end
end
