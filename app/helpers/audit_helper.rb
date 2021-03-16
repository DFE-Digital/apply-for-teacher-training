module AuditHelper
  def change_by_support?(audit)
    audit.user.is_a?(SupportUser) || !!(audit.username =~ /via the Rails console/)
  end
end
