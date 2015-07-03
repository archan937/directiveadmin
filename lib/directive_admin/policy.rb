module DirectiveAdmin
  class Policy
    attr_reader :user, :subject

    def self.additional_actions
      (instance_methods(false) - DirectiveAdmin::Policy.instance_methods).collect{|x| x.to_s.gsub!(/\?$/, "")}.compact
    end

    def initialize(user, subject)
      @user = user
      @subject = subject
    end

    def index?
      authorized? :index
    end

    def create?
      authorized? :create
    end

    def update?
      authorized? :update
    end

    def destroy?
      authorized? :destroy
    end

    def read?; index? ; end
    def new? ; create?; end
    def edit?; update?; end

    def column?
      authorized? :columns, true
    end

    def row?
      authorized? :rows, true
    end

    def list?
      authorized? :lists, true
    end

    def details?
      true
    end

    def panel?(autogrant_admin = true)
      authorized? :panels, true, autogrant_admin
    end

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        scope!
        authorize! unless user.admin?
        scope
      end

      def scope!
        # override this
      end

      def authorize!
        # override this
      end

      def where!(sql)
        @scope = scope.where(sql)
      end

      def scope?(subject)
        !user.admin? && scope_authorization.include?(subject)
      end

    private

      def scope_authorization
        @scope_authorization ||= begin
          namespace = self.class.name.gsub(/Policy::Scope$/, "").underscore
          (user.authorization[namespace] || {})["scope"] || []
        end
      end

    end

  private

    def authorized?(key, included = false, autogrant_admin = true)
      return true if autogrant_admin && user.admin?
      included ? authorized(key, []).include?(normalized_subject) : authorized(key)
    end

    def authorized(key, default = false)
      authorization.fetch key.to_s, default
    end

    def authorization
      @authorization ||= begin
        namespace = self.class.name.gsub(/Policy$/, "").underscore
        user.authorization[namespace] || {}
      end
    end

    def normalized_subject
      DirectiveAdmin::AuthorizationAdapter.normalize subject
    end

  end
end
