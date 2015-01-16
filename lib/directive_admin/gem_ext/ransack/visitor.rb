module Ransack
  class Visitor

    def visit_and(object)
      nodes = object.values.map { |o| accept(o) }.compact
      return nil unless nodes.size > 0

      nodes = nodes.collect{|x| x.is_a?(String) ? Arel.sql(x) : x}

      if nodes.size > 1
        Arel::Nodes::Grouping.new(Arel::Nodes::And.new(nodes))
      else
        nodes.first
      end
    end

  end
end
