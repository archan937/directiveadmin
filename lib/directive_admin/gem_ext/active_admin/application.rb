module ActiveAdmin
  class Application

    inheritable_setting :route_prefix, nil

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
