ActiveAdmin.after_load do |app|
  if comments = DirectiveAdmin.namespace.instance_variable_get(:@resources)[ActiveAdmin::Comment]
    route_prefix = DirectiveAdmin.namespace.route_prefix
    comments.page_presenters[:index][:table].instance_variable_set :@block, proc {
      column "Resource", "resource_type" do |row|
        resource_name = DirectiveAdmin.namespace.resources[row["resource_type"]].resource_name
        "<a href='/#{route_prefix}/#{resource_name.route_key}/#{row["resource_id"]}'>#{resource_name.human} ##{row["resource_id"]}</a>".html_safe
      end
      column "Author", "author_id" do |row|
        "<a href='/#{route_prefix}/users/#{row["author_id"]}'>User ##{row["author_id"]}</a>".html_safe
      end
      column "Comment", "body"
      column "", "resource_id" do |row|
        "<a href='/#{route_prefix}/comments/#{row["id"]}'>View</a>".html_safe
      end
      actions
    }
    comments.menu_item_options[:priority] = 5
  end
end
