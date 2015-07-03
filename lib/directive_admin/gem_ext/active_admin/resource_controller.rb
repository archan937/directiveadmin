require "directive_admin/gem_ext/active_admin/resource_controller/data_access"

module ActiveAdmin
  class ResourceController < BaseController

    def show
      show! do |format|
        format.js { render partial: "#{controller_name}/show", locals: {resource_class.name.underscore.to_sym => resource} }
      end
    end

    def new
      new! do |format|
        format.js { render partial: "#{controller_name}/form", locals: {resource_class.name.underscore.to_sym => resource} }
      end.tap do |response|
        if (request.format.to_sym == :html) && (referer = request.referer) && ((referer = URI(referer).path) != request.path)
          response[0].gsub!(/<form .*?>/) do |form|
            "#{form}<input type='hidden' name='_referer' value='#{referer}'>"
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
        format.js { render partial: "#{controller_name}/show", locals: {resource_class.name.underscore.to_sym => resource} }
      end
    end

    def edit
      edit! do |format|
        format.js { render partial: "#{controller_name}/form", locals: {resource_class.name.underscore.to_sym => resource} }
      end.tap do |response|
        if (request.format.to_sym == :html) && (referer = request.referer) && ((referer = URI(referer).path) != request.path)
          response[0].gsub!(/<form .*?>/) do |form|
            "#{form}<input type='hidden' name='_referer' value='#{URI(referer).path}'>"
          end
        end
      end
    end

    def update
      options = {}
      if (request.format.to_sym == :html) && (referer = params[:_referer])
        options[:location] = referer
      end
      update!(options) do |format|
        format.js { render partial: "#{controller_name}/show", locals: {resource_class.name.underscore.to_sym => resource} }
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

  end
end
