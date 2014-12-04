module DirectiveAdmin
  class AuthorizationAdapter < ActiveAdmin::AuthorizationAdapter
    module TreeDefinition

      def tree
        DirectiveAdmin.namespace.fetch_menu(:default)

        children = DirectiveAdmin.namespace.resources.values.sort_by{|x| x.menu_item.priority}.collect do |resource|
          menu_item = resource.menu_item
          resource_page = resource.is_a?(ActiveAdmin::Resource)
          key = (resource_page ? resource.resource_class.name : menu_item.id).underscore.to_sym

          label = menu_item.label
          name = "#{key}[index]" unless menu_item.id == "dashboard"
          definition = resource_page ? resource_definition(key) : panels_definition(key, :index)

          {label: label, name: name, children: definition}.reject{|k, v| v.nil?}
        end

        [
          {
            :label => "#{DirectiveAdmin.namespace.name.to_s.humanize} interface",
            :bulk_select => true,
            :children => children
          }
        ]
      end

      def permitted
        permitted = [:_]
        extract_names(tree).each do |name|
          name = name.dup
          last = name.pop

          array = name.inject(permitted) do |a, k|
            h = a[-1]
            a.push(h = {}) unless h.is_a?(Hash)
            h[k] ||= []
          end

          array.insert((array[-1].is_a?(Hash) ? -2 : -1), last) unless last == :[]
        end
        permitted
      end

    private

      def extract_names(array)
        array.inject([]) do |names, entry|
          name, children = entry.values_at :name, :children
          children = extract_names(children) if children

          names << name.scan(/([\w\/]+|\[\])/).flatten.collect(&:to_sym) if name
          names.concat children unless children.blank?

          names.uniq! || names
        end
      end

      def scope_definition(resource, keys, label = nil)
        children = keys.collect do |key|
          {
            :label => "Only #{"related to " unless key.to_sym == :id}the assigned #{(key == :id ? resource : key).to_s.pluralize.gsub("_", " ")}",
            :name => "#{resource}[scope][#{key}]"
          }
        end
        {:label => label || resource.to_s.pluralize.humanize, :italic => true, :children => children}
      end

      def resource_definition(key)
        actions_definition(key) +
        columns_definition(key) +
        rows_definition(key) +
        panels_definition(key, :show) +
        lists_definition(key)
      end

      def actions_definition(key)
        resource = resource_for_key(key)
        action_methods = resource.controller.action_methods
        policy = "#{resource.controller.resource_class.name}Policy".constantize.new nil, nil

        actions = [
          {:label => "Create", :name => "create", :method => "new"},
          {:label => "Update", :name => "update", :method => "edit"},
          {:label => "Destroy", :name => "destroy", :method => "destroy"}
        ]

        children = actions.collect do |spec|
          label, name, method = spec.values_at :label, :name, :method
          if action_methods.include?(method) && (policy.send(:"#{name}?") rescue nil).nil?
            {:label => label, :name => "#{key}[#{name}]"}
          end
        end.compact

        policy.class.additional_actions.each do |action|
          children << {:label => action.to_s.humanize, :name => "#{key}[#{action}]"}
        end

        children.empty? ? [] : [{:label => "Actions", :italic => true, :children => children}]
      end

      def columns_definition(key)
        compose_definition(key, :column) do |page_presenters|
          page_presenters[:index][:table]
        end.tap do |definition|
          call_stack = track_calls key do |page_presenters|
            page_presenters[:index][:table]
          end
          unless call_stack[:id_column].blank?
            definition[0][:children].unshift :name => "#{key}[columns][]", :label => "ID", :value => "id"
          end
        end
      end

      def rows_definition(key)
        compose_definition key, :row, {:label => "Attributes", :track => :attributes_table} do |page_presenters|
          page_presenters[:show] || begin

            resource = resource_for_key(key)
            action_methods = resource.controller.action_methods
            policy = "#{resource.controller.resource_class.name}Policy".constantize.new nil, nil

            if action_methods.include?("show") && (policy.send(:show?) rescue nil) != false
              names = resource.resource_class.columns.collect{|column| column.name.to_sym}
              block = proc {
                attributes_table do
                  names.each{|name| row name}
                end
              }
              Struct.new(:block).new(block)
            end

          end
        end
      end

      def panels_definition(key, page)
        collection_panel = compose_definition key, :collection_panel do |page_presenters|
          page_presenters[page]
        end
        panel = compose_definition(key, :panel) do |page_presenters|
          page_presenters[page]
        end
        children = [(collection_panel[0] || {})[:children], (panel[0] || {})[:children]].flatten.compact
        if children.any?
          children.each do |child|
            child[:label] << " (0)" if child[:name].include?("collection_")
            child[:name].gsub! "collection_", ""
          end
          [{:label => "Panels", :italic => true, :children => children}]
        else
          []
        end
      end

      def lists_definition(key)
        compose_definition key, :list do |page_presenters|
          page_presenters[:show]
        end
      end

      def compose_definition(key, type, options = {}, &block)
        call_stack = track_calls key, options[:track], &block

        children = (call_stack[type.to_sym] || []).collect do |args, blck|
          opts = args.extract_options!
          args.pop if [true, false].include? args[-1]
          args = args.collect(&:to_s)
          label = args[1] ? args[0] : args[0].humanize
          value = args[1] || args[0]
          {
            :name => "#{key}[#{type.to_s.pluralize}][]",
            :label => label,
            :value => normalize(value)
          } unless label.blank? || opts[:authorize]
        end.compact

        children.present? ? [{:label => options[:label] || type.to_s.pluralize.humanize, :italic => true, :children => children}] : []
      end

      def track_calls(key, track = nil)
        resource = resource_for_key(key)
        block = yield(resource.page_presenters).try(:block)

        call_stack = CallStack.new
        call_stack.track! track, &block if block
        call_stack.calls
      end

      def resource_for_key(key)
        DirectiveAdmin.namespace.resources.detect{|x| (x.resource_class.name rescue x.menu_item.id).underscore == key.to_s}
      end

    end
  end
end
