module DirectiveAdmin
  class CallStack < BasicObject
    class SilentObject < BasicObject

      def to_s
        ({:size => 0}[@name] if @name).to_s
      end

      def html_safe
        to_s
      end

    private

      def method_missing(name, *args, &block)
        @name = name
        self
      end

    end
  end
end
