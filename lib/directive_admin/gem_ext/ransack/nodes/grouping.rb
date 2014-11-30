module Ransack
  module Nodes
    class Grouping < Node

      def attribute_method?(name)
        name = strip_predicate_and_index(name)
        case name
        when /^(g|c|m|groupings|conditions|combinator)=?$/
          true
        when DirectiveAdmin::PATH_REGEX
          true
        else
          name.split(/_and_|_or_/)
          .select { |n| !@context.attribute_method?(n) }
          .empty?
        end
      end

    end
  end
end
