module ActiveAdmin
  module Views
    module Pages
      class Base < Arbre::HTML::Document

        def cake_status_tag(object)
          return unless (status = object["account_status.name"])
          status_tag status, {"Active" => :ok, "Inactive" => :error, "Pending" => :warn}[status]
        end

        def collection_panel(name, &block)
          collection = scope resource.send(name)
          label = name.to_s.humanize
          panel "#{label} (#{collection.size})" do
            if collection.empty?
              span "No #{label.downcase} yet."
            else
              table_for collection, &block
            end
          end
        end

        alias :original_panel :panel

        def panel(*args, &block)
          options = args.extract_options!
          return unless options.delete(:details) ? authorized?(:details, resource) : authorized?(:panel, args[0], nil, (args.size == 2 ? args[1] : true))
          original_panel *args.slice(0, 1).push(options), &block
        end

        def scope(collection)
          klass = collection.klass
          scoped_collection = active_admin_authorization.scope_collection(collection)
          klass.instantiate_all scoped_collection.qry_options[:where], scoped_collection
        end

      end
    end
  end
end
