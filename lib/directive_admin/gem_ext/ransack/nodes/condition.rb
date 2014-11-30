module Ransack
  module Nodes
    class Condition < Node

      NodeMock = Struct.new(:left, :right)

      def arel_predicate
        predicates = attributes.map do |attr|
          if attr.name.match(DirectiveAdmin::PATH_REGEX)
            to_sql = Arel::Visitors::ToSql.new ActiveRecord::Base.connection
            node = NodeMock.new Arel.sql(attr.name), Arel.sql(to_sql.send(:quote, predicate.format(value)))
            to_sql.send(:"visit_Arel_Nodes_#{predicate.arel_predicate.camelize}", node, nil)
          else
            attr.attr.send(
              predicate.arel_predicate, formatted_values_for_attribute(attr)
            )
          end
        end

        if predicates.size > 1
          case combinator
          when "and"
            Arel::Nodes::Grouping.new(Arel::Nodes::And.new(predicates))
          when "or"
            predicates.inject(&:or)
          end
        else
          predicates.first
        end
      end

    end
  end
end
