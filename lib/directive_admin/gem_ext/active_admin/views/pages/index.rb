module ActiveAdmin
  module Views
    module Pages
      class Index < Base

        alias :original_build_collection :build_collection

        def build_collection
          if active_admin_config.inline_edit
            render_index
            meta name: "inline-editable", content: "yes"
          else
            original_build_collection
          end
        end

      end
    end
  end
end
