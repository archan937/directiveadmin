require "activeadmin"
require "pundit"
require "directiverecord"

require "directive_admin/call_stack"
require "directive_admin/policy"
require "directive_admin/pundit_adapter"

ActiveAdmin.after_load do
  require "directive_admin/gem_ext"
end

module DirectiveAdmin

  PATH_REGEX = /^\w+(\.\w+)+$/

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
