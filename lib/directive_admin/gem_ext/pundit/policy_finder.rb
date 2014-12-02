module Pundit
  class PolicyFinder

  private

    alias :original_find :find

    def find
      if object.is_a?(ActiveRecord::Associations::CollectionProxy)
        "#{object.klass}Policy"
      else
        original_find
      end
    end

  end
end
