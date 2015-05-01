module ActiveAdmin
  class Application

    inheritable_setting :body_classes, []
    inheritable_setting :route_prefix, nil

    attr_reader :selected_namespace

    def select_namespace!(namespace)
      self.default_namespace = @selected_namespace = namespace.to_sym
    end

    alias_method :original_namespaces, :namespaces

    def namespaces
      original_namespaces.select!{|k, v| k.to_sym == selected_namespace} if selected_namespace
      original_namespaces
    end

    def all_javascripts
      namespaces.inject(Set.new) do |js, (name, namespace)|
        js + namespace.javascripts
      end
    end

    def all_stylesheets
      namespaces.inject({}) do |css, (name, namespace)|
        css.merge namespace.stylesheets
      end
    end

  end
end
