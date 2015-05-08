module ActiveAdmin
  module Views
    class List < ActiveAdmin::Component

      builder_method :list

      def build(title, &block)
        name = title.underscore
        return unless authorized?(:list, name, resource.class)

        @select = []
        yield if block_given?

        keys = @select.to_a
        @select += @select.collect do |path|
          (segments = path.split(".")).pop
          (segments + ["id"]).join(".")
        end
        @select.uniq!

        collection = active_admin_authorization.scope_collection(resource.send(name))
        klass = collection.klass
        qry_options = collection.qry_options(*@select).merge(:group_by => "id", :order_by => keys) rescue binding.pry

        collection = klass.connection.select_all(klass.to_qry(qry_options)).group_by{|x| x.values_at(*keys)}.values.collect do |data|
          attributes = data.first
          klass.instantiate attributes
        end

        add_class "panel"
        h3 "#{title} (#{collection.size})"
        div class: "panel_contents" do
          ul :class => name, :"data-parent" => "#{resource.class.reflect_on_association(name.to_sym).foreign_key}##{resource.id}" do
            key = name.singularize.to_sym
            collection.each do |record|
              render partial: "#{name}/show", locals: {key => record}
            end
          end
          if authorized? :create, klass
            div :class => "container" do
              a :href => "#", :class => "create" do
                "Create a#{"n" if %w(a e i u o).include? name[0]} #{name.singularize}"
              end
            end
          elsif collection.empty?
            div :class => "container" do
              span do
                "No #{name.humanize.downcase} yet"
              end
            end
          end
        end
      end

      def add(attribute)
        (@select ||= []) << attribute.to_s
      end

    end
  end
end
