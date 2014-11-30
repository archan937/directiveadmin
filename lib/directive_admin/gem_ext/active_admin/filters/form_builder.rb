module ActiveAdmin
  module Filters
    class FormBuilder < ::ActiveAdmin::FormBuilder

      def filter(method, options = {})
        if method.present? && options[:as] ||= default_input_type(method)
          options = options.merge(:label => method.to_s.split(".").collect{|x| x.singularize.humanize}.join(" ")) if !options[:label] && method.to_s.match(DirectiveAdmin::PATH_REGEX)
          template.concat input(method, options)
        end
      end

    protected

      alias :original_default_input_type :default_input_type

      def default_input_type(method, options = {})
        original_default_input_type(method, options) || (:string if method.match(DirectiveAdmin::PATH_REGEX))
      end

    end
  end
end
