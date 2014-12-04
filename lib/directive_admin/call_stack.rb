require "directive_admin/call_stack/silent_object"

module DirectiveAdmin
  class CallStack < BasicObject

    def [](key)
      calls[key]
    end

    def calls
      @calls ||= {}
    end

    def track!(*included, &block)
      @included = included.flatten.compact
      calls.clear
      @locked = false
      instance_exec &block
      @locked = true
    end

    def inspect; end

  private

    def included
      @included || []
    end

    def method_missing(name, *args, &block)
      return if @locked
      (calls[name] ||= []) << [args, block]
      instance_exec &block if included.include?(name)
      @silent_object ||= SilentObject.new
    end

  end
end
