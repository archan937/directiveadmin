module ActiveAdmin
  module Views
    class List < ActiveAdmin::Component

      builder_method :list

      def build(title, options = {}, &block)
        name = title.underscore
        return unless authorized?(:list, name, resource.class)

        @select = []
        instance_exec(&block) if block_given?

        keys = @select.to_a
        @select += @select.collect do |path|
          (segments = path.split(".")).pop
          (segments + ["id"]).join(".")
        end
        @select.uniq!

        collection = active_admin_authorization.scope_collection(resource.send(name))
        klass = collection.klass
        default_attributes = Hash[klass.column_names.zip]
        qry_options = collection.qry_options(*@select).merge(:group_by => "id").reverse_merge(:order_by => keys)

        collection = klass.connection.select_all(klass.to_qry(qry_options)).group_by{|x| x.values_at(*keys)}.values.collect do |data|
          attributes = data.first
          klass.instantiate default_attributes.merge(attributes)
        end

        create = (options[:create] != false) && authorized?(:create, klass)

        add_class "panel"
        h3 "#{title} (#{collection.size})"
        div class: "panel_contents" do
          ul :class => "#{name} #{"no-create" unless create}".strip, :"data-parent" => "#{resource.class.reflect_on_association(name.to_sym).foreign_key}##{resource.id}" do
            key = name.singularize.to_sym
            begin
              collection.each do |record|
                render partial: "#{name}/show", locals: {key => record}
              end
            rescue ActionView::MissingTemplate
              collection.each do |record|
                li keys.collect{|attribute| record.send(attribute)}.join(" / ")
              end
            end
          end
          if create
            div :class => "container" do
              a :href => "#", :class => "create", :"data-no-turbolink" => "true" do
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
