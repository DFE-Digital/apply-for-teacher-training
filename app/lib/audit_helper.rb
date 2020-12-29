module AuditHelper
  def audit(actor)
    impersonator = actor.try(:impersonator)

    Audited.audit_class.as_user(impersonator || actor) do
      yield
    end
  end
end
