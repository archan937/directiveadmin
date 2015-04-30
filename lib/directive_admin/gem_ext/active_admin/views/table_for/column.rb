module ActiveAdmin
  module Views
    class TableFor < Arbre::HTML::Table
      class Column

        def initialize(*args, &block)
          @options = args.extract_options!
          @title = args[0]
          @data = key = args[1] || args[0]
          @data = block if block
          @resource_class = args[2]

          key.gsub!(/^.+ AS /, "") if key.is_a?(String)

          unless @options.include?(:precision)
            if column = @options[:klass].columns_hash[key]
              case column.type
              when :integer
                @options[:precision] = 0
              else
                @options[:precision] = column.scale
              end
            end
          end

          html_classes = [:col]
          if @options[:right] || @options[:unit] || @options[:precision]
            html_classes << "align-right"
          end
          if @options.has_key?(:class)
            html_classes << @options.delete(:class)
          elsif @title.present?
            html_classes << "col-#{@title.to_s.parameterize("_")}"
          end
          @html_class = html_classes.join(' ')

          @options[:sortable] = key unless @options[:sortable] == false

          url_prefix = DirectiveAdmin.namespace.name

          if (@options[:unit] || @options[:precision]) && !@data.is_a?(Proc)
            @data = proc { |row|
              @options[:unit] ||= ""
              value = row[key]
              ActiveSupport::NumberHelper.number_to_currency value, @options
            }
          end

          if @options[:link_to]
            id = key.gsub(/\w+$/, "id")
            path = "/#{url_prefix}/#{key.split(".")[0..-2].inject(@options[:klass]) do |klass, association|
              klass.reflect_on_association(association.to_sym).klass
            end.name.tableize}"
            @data = proc { |row|
              text = row[key]
              "<a href='#{path}/#{row[id]}'>#{text}</a>".html_safe unless text.blank?
            }
          end

          if @options[:links_to]
            id = key.gsub(/\w+$/, "id")
            path = "/#{url_prefix}/#{key.split(".")[0..-2].inject(@options[:klass]) do |klass, association|
              klass.reflect_on_association(association.to_sym).klass
            end.name.tableize}"
            @data = proc { |row|
              row[key.gsub(".", "_")].to_s.split(";,").collect do |text|
                text.gsub! /;$/, ""
                split = text.split(":")
                id, text = split.shift, split.join(":")
                "<a href='#{path}/#{id}'>#{text}</a>" unless text.blank?
              end.compact.join(", ").html_safe
            }
          end

          if @options[:status_tag]
            @data = proc { |row|
              text = row[key] == 1 ? "Yes" : "No"
              klass = row[key] == 1 ? "ok" : "error"
              "<span class='status_tag #{klass}'>#{text}</span>".html_safe
            }
          end
        end

      end
    end
  end
end
