class LaunchMakeDecisionsAndManageUsers
  include Sidekiq::Worker

  def perform(*)
    Audited.audit_class.as_user('LaunchMakeDecisionsAndManageUsers task') do
      give_manage_users_to_the_user_who_has_signed_the_dsa!

      return unless all_providers_have_at_least_one_user_with_manage_users?

      ProviderPermissions.update_all(make_decisions: true)
      FeatureFlag.activate(:providers_can_manage_users_and_permissions)
    end
  end

  def give_manage_users_to_the_user_who_has_signed_the_dsa!
    ProviderAgreement.data_sharing_agreements.find_each do |a|
      user_permissions = a.provider_user.provider_permissions.find_by(provider: a.provider)
      user_permissions.update(manage_users: true)
    end
  end

  def all_providers_have_at_least_one_user_with_manage_users?
    # ignore providers with no users
    Provider.joins(:provider_users).distinct.find_each.all? do |provider|
      provider.provider_permissions.any?(&:manage_users)
    end
  end
end
