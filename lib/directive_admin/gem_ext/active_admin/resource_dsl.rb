module ActiveAdmin
  class ResourceDSL < DSL

    def dossier_scope
      scope :all, :default => true, :if => proc{ authorized?(:can_scope, Dossier) }
      Dossier.order(:description).each do |dossier|
        code = dossier.code
        scope code.to_sym, nil, :if => proc{ authorized?(:can_scope, dossier) } unless code.ends_with?("_csv")
      end
    end

  end
end
