module ProviderInterface
  class ProviderUserForm < SupportInterface::ProviderUserForm
    attr_accessor :current_provider_user

    validate :permitted_providers

    def available_providers
      @available_providers ||= Provider
        .with_users_manageable_by(current_provider_user)
        .order(name: :asc)
    end

  private

    def permitted_providers
      return unless provider_ids.any?
      return if provider_ids_valid?

      errors.add(:provider_ids, 'insufficient permissions to manage users for this provider')
    end

    def provider_ids_valid?
      integer_provider_ids = provider_ids.map(&:to_i)
      (integer_provider_ids & available_providers.pluck(:id)) == integer_provider_ids
    end
  end
end
