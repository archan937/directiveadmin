module Ransack
  module Nodes
    class Attribute < Node

      alias :original_valid? :valid?
      alias :original_type :type

      def valid?
        name.to_s.match(DirectiveAdmin::PATH_REGEX) || original_valid?
      end

      def type
        name.to_s.match(DirectiveAdmin::PATH_REGEX) ? :string : original_type
      end

    end
  end
end
