require "directive_admin/call_stack/silent_object"

module DirectiveAdmin
  class CallStack < BasicObject

    def [](key)
      if key.is_a?(::Fixnum)
        to_a[key]
      else
        to_h[key]
      end
    end

    def to_h
      @to_h ||= calls.inject({}) do |hash, call|
        (hash[call[0]] ||= []) << call[1..-1]
        hash
      end
    end

    def to_a
      calls
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

    def calls
      @calls ||= []
    end

    def included
      @included || []
    end

    def method_missing(name, *args, &block)
      return if @locked
      calls << [name, args, block]
      instance_exec &block if included.include?(name)
      @silent_object ||= SilentObject.new
    end

  end
end
