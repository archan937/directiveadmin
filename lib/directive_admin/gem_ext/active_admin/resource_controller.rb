require "directive_admin/gem_ext/active_admin/resource_controller/data_access"

module ActiveAdmin
  class ResourceController < BaseController

    def show
      show! do |format|
        format.js { render_show }
      end
    end

    def new
      new! do |format|
        format.js { render_form }
      end.tap do |response|
        if (request.format.to_sym == :html) && (referer = request.referer) && ((referer = URI(referer).path) != request.path)
          response[0].gsub!(/<form .*?>/) do |form|
            "#{form}<input type='hidden' name='_referer' value='#{referer}'>"
          end
        end
      end
    end

    def edit
      edit! do |format|
        format.js { render_form }
      end.tap do |response|
        if (request.format.to_sym == :html) && (referer = request.referer) && ((referer = URI(referer).path) != request.path)
          response[0].gsub!(/<form .*?>/) do |form|
            "#{form}<input type='hidden' name='_referer' value='#{URI(referer).path}'>"
          end
        end
      end
    end

    def create
      options = {}
      if (request.format.to_sym == :html) && (referer = params[:_referer])
        options[:location] = referer
      end
      create!(options) do |format|
        format.js { render_show }
      end
    end

    def update
      options = {}
      if (request.format.to_sym == :html) && (referer = params[:_referer])
        options[:location] = referer
      end
      update!(options) do |format|
        format.js { render_show }
      end
    end

    alias :original_find_collection :find_collection

    def find_collection
      collection = original_find_collection

      if %w(csv xml json).include?(params[:format])
        options = {exclude: [:limit, :offset, :order_by], authorization: active_admin_authorization}
      end

      DirectiveAdmin.to_table_collection collection, options, &active_admin_config.instance_variable_get(:@page_presenters)[:index][:table].block
    end

    def find_resource
      collection = apply_authorization_scope(scoped_collection)
      collection = collection.all unless collection.respond_to?(:klass)
      klass = collection.klass

      conditions = collection.qry_options[:where] || []
      conditions.unshift "id = #{params[:id].to_i}"

      klass.instantiate_all(conditions).first || begin
        raise ActiveAdmin::AccessDenied.new current_active_admin_user, action_to_permission(params[:action]), nil
      end
    end

  private

    def form_columns
      if active_admin_config.inline_edit
        @inline_form_inputs ||= begin
          call_stack = DirectiveAdmin::CallStack.new
          call_stack.track! &active_admin_config.page_presenters[:index][:table].block
          call_stack.to_a.select{|x| [:column, :actions].include?(x[0])}.collect do |call|
            call_to_form_column *call
          end
        end
      end
    end

    def call_to_form_column(method, args, block)
      case method
      when :column
        block = args.pop if args[-1].is_a?(Proc)
        options = args.extract_options!
        options[:name] ||= args[0]
        options[:label] = false
        options unless %w(id created_at updated_at).include?(options[:name]) || (options[:editable] == false)
      when :actions
        {:actions => true}
      end
    end

    def render_show
      if form_columns
        render partial: "inline_row"
      else
        render partial: "#{controller_name}/show", locals: {resource_class.name.underscore.to_sym => resource}
      end
    end

    def render_form
      if form_columns
        render partial: "directive_admin/inline_form", locals: {:form_columns => form_columns}
      else
        render partial: "#{controller_name}/form", locals: {resource_class.name.underscore.to_sym => resource}
      end
    end

  end
end
