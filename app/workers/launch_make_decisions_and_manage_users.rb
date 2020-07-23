class LaunchMakeDecisionsAndManageUsers
  include Sidekiq::Worker

  def perform(*)
    return unless all_providers_have_at_least_one_user_with_manage_users?

    Audited.audit_class.as_user('LaunchMakeDecisionsAndManageUsers') do
      ProviderPermissions.update_all(make_decisions: true)
      FeatureFlag.activate(:providers_can_manage_users_and_permissions)
    end
  end

  def all_providers_have_at_least_one_user_with_manage_users?
    Provider.find_each.all? do |provider|
      provider.provider_permissions.any?(&:manage_users)
    end
  end
end
