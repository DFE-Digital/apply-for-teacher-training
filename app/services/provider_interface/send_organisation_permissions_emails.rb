module ProviderInterface
  class SendOrganisationPermissionsEmails
    def initialize(provider_user:, permissions:, provider: nil)
      @provider_user = provider_user
      @permissions = permissions
      @provider = provider
    end

    def call
      managing_users.uniq.each do |user|
        ProviderMailer.send("organisation_permissions_#{email_to_send}", user, partner_organisation, @permissions).deliver_later
      end
    end

  private

    attr_reader :permissions, :provider, :provider_user

    def managing_users
      ProviderUser.joins(:provider_permissions)
        .where(ProviderPermissions.table_name => { provider: partner_organisation, manage_organisations: true })
    end

    def email_to_send
      provider.nil? ? 'set_up' : 'updated'
    end

    def partner_organisation
      if provider.present?
        permissions.partner_organisation(provider)
      elsif provider_user_belongs_to_both_providers?
        alphabetically_first_provider_in_relationship
      elsif provider_user.providers.include?(permissions.ratifying_provider)
        permissions.training_provider
      else
        permissions.ratifying_provider
      end
    end

    def provider_user_belongs_to_both_providers?
      (providers_in_relationship & provider_user.providers) == providers_in_relationship
    end

    def providers_in_relationship
      @providers_in_relationship ||= [permissions.training_provider, permissions.ratifying_provider]
    end

    def alphabetically_first_provider_in_relationship
      providers_in_relationship.min_by(&:name)
    end
  end
end
