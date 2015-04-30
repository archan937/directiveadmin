module ActiveAdmin
  module Views
    class IndexAsTable < ActiveAdmin::Component
      class IndexTableFor < ::ActiveAdmin::Views::TableFor

        def id_column
          column "id" do |row|
            id = row["id"]
            if controller.action_methods.include?("show")
              link_to id, "/#{DirectiveAdmin.namespace.route_prefix}/#{@resource_class.name.tableize}/#{id}"
            else
              id
            end
          end
        end

      private

        def defaults(row, options = {})
          path = "/#{DirectiveAdmin.namespace.route_prefix}/#{@resource_class.name.demodulize.tableize}/#{row["id"]}"
          if controller.action_methods.include?("show") && authorized?(ActiveAdmin::Auth::READ, row)
            item I18n.t("active_admin.view"), path, class: "view_link #{options[:css_class]}"
          end
          if controller.action_methods.include?("edit") && authorized?(ActiveAdmin::Auth::UPDATE, row)
            item I18n.t("active_admin.edit"), "#{path}/edit", class: "edit_link #{options[:css_class]}"
          end
          if controller.action_methods.include?("destroy") && authorized?(ActiveAdmin::Auth::DESTROY, row)
            item I18n.t("active_admin.delete"), path, class: "delete_link #{options[:css_class]}", method: :delete, data: {confirm: I18n.t("active_admin.delete_confirmation")}
          end
        end

      end
    end
  end
end
