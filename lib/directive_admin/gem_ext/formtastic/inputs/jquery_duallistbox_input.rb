module Formtastic
  module Inputs
    class JqueryDuallistboxInput < SelectInput
      include Base::JqueryDriven

    private

      def inputs_html
        select_html
      end

      def foreign_key
        association = object.class.name.underscore
        association = association.pluralize if reflection.is_a?(ActiveRecord::Reflection::ThroughReflection)
        "#{association}.id"
      end

      def collection_from_options
        if options[:collection] == :ajax
          return [] if object.new_record?

          klass = reflection.klass

          qry_options = {:limit => 1000}
          qry_options[:select] = %w(name id)
          qry_options[:where] = ["#{foreign_key} = #{object.id}"]
          qry_options.merge!(options[:qry_options] || {})

          klass.qry qry_options

        elsif options[:collection].is_a?(Proc)
          instance_exec &options[:collection]
        else
          super
        end
      end

      def script_html
        (
        <<-HTML
          <script>
            $('##{dom_id}').bootstrapDualListbox({
              nonSelectedListLabel: 'Available',
              selectedListLabel: 'Selected',
              nonSelectedFilterPlaceHolder: '#{"Type at least 2 characters" if options[:collection] == :ajax}',
           #{"remoteJsonData: '/data/#{reflection.name}.json#{"?foreign_key=#{foreign_key}&foreign_id=#{object.id}" unless object.new_record?}'," if options[:collection] == :ajax}
           #{"infoText: 'Showing {0}'," if options[:collection] == :ajax}
           #{"nonSelectedFilterTextClear: false," if options[:collection] == :ajax}
              selectorMinimalHeight: 400
            });
          </script>
        HTML
        ).html_safe
      end

    end
  end
end
