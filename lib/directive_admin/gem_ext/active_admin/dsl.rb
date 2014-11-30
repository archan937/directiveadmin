module ActiveAdmin
  class DSL

    alias :original_menu :menu

    def menu(options = {})
      original_menu(options == :hide ? {:if => proc{false}} : options)
    end

  end
end
