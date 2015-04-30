module ActiveAdmin
  class Router

    def define_root_routes(router)
      router.instance_exec @application.namespaces.values do |namespaces|
        namespaces.each do |namespace|
          if namespace.root?
            root namespace.root_to_options.merge(to: namespace.root_to)
          else
            options = namespace.route_prefix ? {path: namespace.route_prefix} : {}
            namespace namespace.name, options do
              root namespace.root_to_options.merge(to: namespace.root_to)
            end
          end
        end
      end
    end

    def define_resource_routes(router)
      router.instance_exec @application.namespaces, self do |namespaces, aa_router|
        resources = namespaces.values.flat_map{ |n| n.resources.values }
        resources.each do |config|
          routes = aa_router.resource_routes(config)

          # Add in the parent if it exists
          if config.belongs_to?
            belongs_to = routes
            routes     = Proc.new do
              # If it's optional, make the normal resource routes
              instance_exec &belongs_to if config.belongs_to_config.optional?

              # Make the nested belongs_to routes
              # :only is set to nothing so that we don't clobber any existing routes on the resource
              resources config.belongs_to_config.target.resource_name.plural, only: [] do
                instance_exec &belongs_to
              end
            end
          end

          # Add on the namespace if required
          unless config.namespace.root?
            nested = routes
            routes = Proc.new do
              options = config.namespace.route_prefix ? {path: config.namespace.route_prefix} : {}
              namespace config.namespace.name, options do
                instance_exec &nested
              end
            end
          end

          instance_exec &routes
        end
      end
    end

  end
end
