require "directive_admin/gem_ext/pundit/policy_finder"

# The following is taken from https://github.com/elabs/pundit/commit/698c9b5cb812d22a78b5c90c5697035b4ec8bcf2

module Pundit

  def policy_scope(scope)
    @_pundit_policy_scoped = true
    policy_scopes[scope] ||= Pundit.policy_scope!(pundit_user, scope)
  end

  def policy(record)
    policies[record] ||= Pundit.policy!(pundit_user, record)
  end

  def policies
    @_pundit_policies ||= {}
  end

  def policy_scopes
    @_pundit_policy_scopes ||= {}
  end

end
