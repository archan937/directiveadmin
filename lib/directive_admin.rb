require "activeadmin"
require "pundit"
require "directiverecord"

require "directive_admin/engine"
require "directive_admin/middleware"
require "directive_admin/impersonator"
require "directive_admin/authorization_adapter"
require "directive_admin/call_stack"
require "directive_admin/policy"

require "directive_admin/gem_ext/active_admin/application"
require "directive_admin/gem_ext/active_admin/namespace"
require "directive_admin/gem_ext/active_admin/router"
require "directive_record/gem_ext/active_record/relation/count"

ActiveAdmin.after_load do
  require "directive_admin/gem_ext"
  config = ActiveAdmin.application

  if current_user_method = config.current_user_method
    actual_user_method = current_user_method.to_s.gsub("current", "actual")
    ApplicationController.send :include, DirectiveAdmin::Impersonator
  end

  config.register_javascript "directive_admin/directive_admin.js"
  config.register_stylesheet "directive_admin/directive_admin.css"

  config.before_filter do
    config.namespace DirectiveAdmin.namespace.name do |admin|
      admin.menus.instance_variable_get(:@menus).delete(key = :utility_navigation)
      admin.menus.menu(key) do |menu|
        admin.add_current_user_to_menu menu
        if current_user_method && (current_user = send(current_user_method)) && UserPolicy.new(send(actual_user_method), nil).impersonate?
          admin.add_impersonable_users_to_menu menu, current_user
        end
        admin.add_logout_button_to_menu menu
      end
    end
  end
end

module DirectiveAdmin

  PATH_REGEX = /^\w+(\.\w+)+$/

  def self.namespace
    ActiveAdmin.application.namespaces[ActiveAdmin.application.default_namespace]
  end

  def self.to_table_collection(collection, options = nil, &block)
    call_stack = CallStack.new
    call_stack.track! &block

    klass = collection.klass
    options ||= {}
    authorization = options[:authorization]

    select = call_stack[:column].inject([]) do |result, (args, block)|
      opts = args.extract_options!
      path = (args[1] || args[0]).to_s
      unless authorization && !authorization.authorized?(:column, path)
        if opts[:links_to]
          result << "GROUP_CONCAT(CONCAT(#{path.gsub(/\w+$/, "id")}, ':', #{path}, ';')) AS #{path.gsub(".", "_")}"
        else
          result << path.gsub(/\w+$/, "id") if opts[:link_to]
          result << path
        end
      end
      result
    end

    select.unshift "id" if klass.columns_hash.include?("id") && !(select.size == 1 && select[0].upcase.include?("COUNT"))
    select.uniq!

    qry_options = collection.qry_options(select)
    qry_options[:optimize] = true
    qry_options[:group_by] = "id" if klass.columns_hash.include?("id")

    select = select.collect{|x| x.match(/ AS (\w+)$/); $1 || x}
    (options[:exclude] || []).each{|x| qry_options.delete x}

    klass.qry(qry_options).collect do |values|
      Hash[select.zip(values)]
    end.tap do |array|
      array.instance_variable_set :@active_relation, collection
      array.instance_variable_set :@select, select
      array.instance_variable_set :@headers, call_stack[:column].collect{|x| x[0][1] ? x[0][0] : x[0][0].to_s.humanize}
      array.instance_variable_set :@values, call_stack[:column].collect{|x| x[0][1] || x[0][0]}
    end
  end

end
