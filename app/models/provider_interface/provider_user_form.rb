module ProviderInterface
  class ProviderUserForm < SupportInterface::ProviderUserForm
    attr_accessor :current_provider_user

    validate :permitted_providers

    def available_providers
      @available_providers ||= Provider
        .with_users_manageable_by(current_provider_user)
        .order(name: :asc)
    end

    def permitted_providers
      return unless provider_ids.any?

      provider_ids.delete('') # TODO: why does this have a blank value?

      return if (provider_ids.map(&:to_i) & available_providers.pluck(:id).map(&:to_i)) == provider_ids.map(&:to_i)

      errors.add(:provider_ids, 'insufficient permissions to manage users for this provider')
    end
  end
end
