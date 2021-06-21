module ProviderInterface
  class ProviderUserProvidersForm
    include ActiveModel::Model
    attr_accessor :current_provider_user, :provider_user, :provider_ids

    validate :at_least_one_provider_is_selected

    def self.from_provider_user(attributes)
      form = new(attributes)
      form.provider_ids = form.provider_user.provider_permissions.pluck(:provider_id)
      form
    end

    def providers_that_actor_can_manage_users_for
      @providers_that_actor_can_manage_users_for ||= current_provider_user.authorisation.providers_that_actor_can_manage_users_for
    end

    def persisted?
      true
    end

    def save
      return unless valid?

      selected_providers.each do |provider|
        ProviderPermissions.find_or_create_by!(provider: provider, provider_user: provider_user)
      end

      not_selected_providers = providers_that_actor_can_manage_users_for - selected_providers

      not_selected_providers.each do |provider|
        permission = ProviderPermissions.find_by(provider: provider, provider_user: provider_user)
        permission&.destroy!
      end

      true
    end

    def at_least_one_provider_is_selected
      if selected_providers.none?
        errors.add(:provider_ids, 'Select which organisations this user will have access to')
      end
    end

    def selected_providers
      @selected_providers ||= providers_that_actor_can_manage_users_for.where(id: provider_ids)
    end
  end
end
