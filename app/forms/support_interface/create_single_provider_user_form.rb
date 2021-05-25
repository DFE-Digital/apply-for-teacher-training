module SupportInterface
  class CreateSingleProviderUserForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :first_name, :last_name, :provider_user, :provider_id
    attr_reader :provider_permissions, :email_address

    validates :first_name, :last_name, :email_address, presence: true
    validates :email_address, valid_for_notify: true
    validates :provider_permissions, presence: true

    def build
      return unless valid?

      @provider_user ||= ProviderUser.find_or_initialize_by(email_address: email_address)
      @provider_user.first_name = first_name
      @provider_user.last_name = last_name
      @provider_user if @provider_user.valid?
    end

    def email_address=(raw_email_address)
      @email_address = raw_email_address.downcase.strip
    end

    def persisted?
      @provider_user&.persisted?
    end

    def permission_form
      ProviderPermissionsForm.new(active: possible_permissions.persisted?, provider_permission: possible_permissions)
    end

    def possible_permissions
      @possible_permissions ||= begin
        if provider_user
          existing_permissions_for_user = ProviderPermissions.includes(:provider, :provider_user).where(provider_user_id: provider_user.id)
        else
          existing_permissions_for_user = []
        end

        provider = Provider.where(id: provider_id).first
        provider_permissions = existing_permissions_for_user.find { |existing_permission| existing_permission.provider_id == provider.id }
        provider_permissions || ProviderPermissions.new(provider: provider)
      end
    end

    def provider_permissions=(attributes)
      return if attributes.empty?

      form = ProviderPermissionsForm.new(attributes)

      @provider_permissions = begin
        permission = ProviderPermissions.find_or_initialize_by(
          provider_id: form.provider_permission[:provider_id],
          provider_user_id: provider_user.try(:id),
        )

        ProviderPermissions::VALID_PERMISSIONS.each do |permission_name|
          permission.send("#{permission_name}=", form.provider_permission.fetch(permission_name, false))
        end

        [permission]
      end
    end
  end
end
