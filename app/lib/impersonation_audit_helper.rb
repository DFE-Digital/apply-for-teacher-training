module ImpersonationAuditHelper
  def audit(actor)
    if ::Audited.store[:audited_user].blank?
      Audited.audit_class.as_user(actor.try(:impersonator) || actor) do
        yield
      end
    else # preserve previously set Audited.audited_class.as_user
      yield
    end
  end
end
