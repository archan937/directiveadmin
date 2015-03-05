module ActiveRecord
  class Base

    def self.instantiate_all(conditions, active_relation = nil)
      conditions = [conditions].flatten.compact
      options = {
        :select => ".*",
        :where => conditions,
        :group_by => ("id" if columns_hash.include?("id"))
      }
      connection.select_all(to_qry(options)).collect{|attrs| instantiate attrs}.tap do |array|
        array.instance_variable_set :@active_relation, active_relation || conditions.inject(all){|x, y| x.where y}
      end
    end

  end
end
