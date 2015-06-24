require "directive_admin/gem_ext/active_admin/views/table_for/column"

module ActiveAdmin
  module Views
    class TableFor < Arbre::HTML::Table

      def column(*args, &block)
        options = default_options.merge(args.extract_options!)

        klass = (@collection.instance_variable_get(:@active_relation) || @collection).klass
        options[:klass] = klass

        if args[0].is_a?(ActiveAdmin::Component)
          title = args[0]
          data  = args[1] || args[0]
        else
          title = args[0].to_s
          title = title.to_s.humanize unless args[1]
          data  = (args[1] || args[0]).to_s
        end

        authorize = options[:authorize]
        authorize ||= [:column, data, klass] unless data == ""
        return if authorize && (authorize[1].class != ActiveAdmin::BatchActions::ResourceSelectionToggleCell) && !authorized?(*authorize)

        if options[:link_to] || options[:links_to]
          association_klass = data.split(".")[0..-2].inject(klass) do |klass, association|
            klass.reflect_on_association(association.to_sym).klass
          end
          unless authorized?(:read, association_klass)
            options.delete :link_to
            options.delete :links_to
          end
        end

        col = Column.new(title, data, @resource_class, options, &block)
        @columns << col

        # Build our header item
        within @header_row do
          build_table_header(col)
        end

        # Add a table cell for each item
        @collection.each_with_index do |item, i|
          within @tbody.children[i] do
            build_table_cell col, item
          end
        end
      end

    protected

      def render_data(data, item)
        value = if data.is_a? Proc
          data.call(item)
        elsif item.respond_to? :[]
          item[data]
        end
        value = pretty_format(value)
        value = "&nbsp;".html_safe if value.blank?
        value
      end

    end
  end
end
