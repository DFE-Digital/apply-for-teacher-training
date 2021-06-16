module SupportInterface
  class CreateSingleProviderUserForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :first_name, :last_name, :provider_user, :provider_id
    attr_reader :provider_permissions, :email_address, :index

    validates :first_name, :last_name, :email_address, presence: true
    validates :email_address, valid_for_notify: true
    validate :user_with_provider_exists?

    def build
      return unless valid?

      @provider_user ||= ProviderUser.find_or_initialize_by(email_address: email_address)
      @provider_user.first_name = first_name
      @provider_user.last_name = last_name
      @provider_user if @provider_user.valid?
    end

    def email_address=(raw_email_address)
      @email_address = raw_email_address.downcase.strip if raw_email_address
    end

    def index=(index)
      @index = index.to_i
    end

    def provider_permissions=(attributes)
      return if attributes.empty?

      form = ProviderPermissionsForm.new(attributes)

      @provider_permissions = begin
        permission = ProviderPermissions.find_or_initialize_by(
          provider_id: provider_id,
          provider_user_id: provider_user.try(:id),
        )

        ProviderPermissions::VALID_PERMISSIONS.each do |permission_name|
          permission.send("#{permission_name}=", form.provider_permission.fetch(permission_name, false))
        end

        permission
      end
    end

    def permission_form
      ProviderPermissionsForm.new(provider_permission: provider_permissions)
    end

  private

    def user_with_provider_exists?
      provider = Provider.find(provider_id)
      provider_user = ProviderUser.where(email_address: email_address).first
      return unless provider_user&.providers&.include?(provider)

      errors.add(:email_address, 'A user with this email address already has permissions for this provider')
    end
  end
end
