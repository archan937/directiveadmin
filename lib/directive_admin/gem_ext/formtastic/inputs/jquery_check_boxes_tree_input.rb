module Formtastic
  module Inputs
    class JqueryCheckBoxesTreeInput
      include Base
      include Base::JqueryDriven

    private

      def inputs_html
        template.content_tag :div, id: dom_id, class: "check_boxes_tree" do
          template.content_tag :div, class: "wrapper" do
            template.concat template.hidden_field_tag expand_name("_")
            template.concat build_tree(options[:tree])
          end
        end
      end

      def bulk_select_html
        "<span><a href='#' class='select'>Select all</a> / <a href='#' class='deselect'>Deselect all</a></span>".html_safe
      end

      def build_tree(arg, parent = nil, bulk_select = false)
        if arg.is_a?(Array)
          template.content_tag(:div, data: ({parent: expand_name(parent)} unless parent.blank?)) do
            template.concat bulk_select_html if bulk_select || (arg.select{|x| x.include?(:name)}.size > 1)
            template.concat arg.collect{|x| build_tree x, parent}.join.html_safe
          end
        else
          label, italic, bulk_select, name, value, children = arg.values_at :label, :italic, :bulk_select, :name, :value, :children
          html = []
          if name
            html << template.content_tag(:label, label, style: ("font-weight: bold" unless children.blank?)) do
              value ||= true
              template.concat template.check_box_tag(*[expand_name(name), value, selected?(name, value)].compact)
              template.concat label
            end
          else
            html << template.content_tag(italic ? :i : :strong, label)
          end
          html << build_tree(children, (name || parent || ""), bulk_select) unless children.blank?
          html.join
        end.html_safe
      end

      def expand_name(name)
        name = name.gsub(/^([\w\/]+)/) { "[#{$1}]" }
        "#{object_name}[#{method}]#{name}"
      end

      def selected?(name, value = true)
        current_value = name.scan(/[\w\/]+/).inject(object_value) do |enum, key|
          val = enum[key]
          val.nil? ? {} : val
        end
        value == true ? (current_value == true) : current_value.include?(value)
      end

      def object_value
        @object_value ||= (object.send(method) || {})
      end

    end
  end
end
