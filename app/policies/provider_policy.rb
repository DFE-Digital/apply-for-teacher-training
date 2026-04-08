class ProviderPolicy < ApplicationPolicy
  def manage_organisation_permissions?
    ProviderAuthorisation.new(actor: user).can_manage_organisation?(provider: record)
  end
end
