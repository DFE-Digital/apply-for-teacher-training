module ProviderInterface
  class SendOrganisationPermissionsEmails
    def initialize(provider_user:, permissions:, set_up: false)
      @provider_user = provider_user
      @permissions = permissions
      @partner_organisation = @permissions.partner_organisation(provider_user)
      @set_up = set_up
    end

    def call
      managing_users.each do |user|
        next if user == @provider_user

        ProviderMailer.send("organisation_permissions_#{email_to_send}", user, @permissions).deliver_later
      end
    end

  private

    def managing_users
      ProviderUser.joins(:provider_permissions)
        .where(ProviderPermissions.table_name => { provider_id: @partner_organisation.id, manage_organisations: true })
    end

    def email_to_send
      @set_up ? 'set_up' : 'updated'
    end
  end
end
