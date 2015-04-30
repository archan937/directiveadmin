ActiveAdmin.after_load do |app|
  if comments = DirectiveAdmin.namespace.instance_variable_get(:@resources)[ActiveAdmin::Comment]
    url_prefix = DirectiveAdmin.namespace.name
    comments.page_presenters[:index][:table].instance_variable_set :@block, proc {
      column "Resource", "resource_type" do |row|
        "<a href='/#{url_prefix}/#{row["resource_type"].tableize}/#{row["resource_id"]}'>#{row["resource_type"]} ##{row["resource_id"]}</a>".html_safe
      end
      column "Author", "author_id" do |row|
        "<a href='/#{url_prefix}/users/#{row["author_id"]}'>User ##{row["author_id"]}</a>".html_safe
      end
      column "Comment", "body"
      column "", "resource_id" do |row|
        "<a href='/#{url_prefix}/comments/#{row["id"]}'>View</a>".html_safe
      end
      actions
    }
    comments.menu_item_options[:priority] = 5
  end
end
