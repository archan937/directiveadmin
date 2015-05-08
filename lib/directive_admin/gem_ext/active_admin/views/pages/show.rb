module ActiveAdmin
  module Views
    module Pages
      class Show < Base

        alias :original_table_for :table_for

        def table_for(*args, &block)
          args[0] = DirectiveAdmin.to_table_collection args[0].spawn, &block unless args[0].is_a?(Array)
          original_table_for *args, &block
        end

        def attributes_table(*args, &block)
          options = args.extract_options!
          panel(options.delete(:title) || I18n.t("active_admin.details", model: active_admin_config.resource_label), options.merge(:details => true)) do
            attributes_table_for resource, *args, &block
          end
        end

      end
    end
  end
end
