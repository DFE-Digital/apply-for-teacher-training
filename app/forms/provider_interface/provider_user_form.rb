module ProviderInterface
  class ProviderUserForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :first_name, :last_name, :provider_user, :current_provider_user
    attr_reader :email_address, :provider_permissions

    validates :first_name, :last_name, presence: true, if: :new_provider_user?
    validates :email_address, presence: true, if: :new_provider_user?
    validates :email_address, email: true, if: :new_provider_user?
    validates :provider_permissions, presence: true
    validate :permitted_providers

    def build
      @provider_user = existing_provider_user || build_new_user

      @provider_user if @provider_user.valid?
    end

    def save
      @provider_user.save! if build
    end

    def email_address=(raw_email_address)
      @email_address = raw_email_address.downcase.strip
    end

    def persisted?
      @provider_user && @provider_user.persisted?
    end

    def self.from_provider_user(provider_user)
      new(
        provider_user: provider_user,
        first_name: provider_user.first_name,
        last_name: provider_user.last_name,
        email_address: provider_user.email_address,
      )
    end

    def existing_provider_user
      return provider_user if provider_user&.persisted?
      return if email_address.blank?

      @existing_provider_user ||= ProviderUser.find_by(email_address: email_address)
    end

    def new_provider_user?
      existing_provider_user.blank?
    end

    def forms_for_possible_permissions
      possible_permissions.map do |p|
        ProviderPermissionsForm.new(active: p.persisted?, provider_permission: p)
      end
    end

    def provider_permissions=(attributes)
      forms = attributes.map { |_, attrs| ProviderPermissionsForm.new(attrs) }.select(&:active)
      @provider_permissions = forms.map do |form|
        permission = ProviderPermissions.find_or_initialize_by(
          provider_id: form.provider_permission[:provider_id],
          provider_user_id: provider_user&.id,
        )

        valid_permissions.each do |permission_name|
          permission.send("#{permission_name}=", form.provider_permission.fetch(permission_name, false))
        end

        permission
      end
    end

    def deselected_provider_permissions
      possible_permissions - @provider_permissions
    end

  private

    def build_new_user
      return unless valid?

      provider_user ||= ProviderUser.new
      provider_user.first_name = first_name
      provider_user.last_name = last_name
      provider_user.email_address = email_address
      provider_user
    end

    def permitted_providers
      return if provider_permissions_valid?

      errors.add(:provider_permissions, 'Insufficient permissions to manage users for this provider')
    end

    def possible_permissions
      ProviderPermissions.possible_permissions(
        current_provider_user: current_provider_user,
        provider_user: provider_user,
      )
    end

    def provider_permissions_valid?
      providers_for_permissions = provider_permissions.map(&:provider)
      providers_for_permissions & possible_permissions.map(&:provider) == providers_for_permissions
    end

    def valid_permissions
      ProviderPermissions::VALID_PERMISSIONS.reject { |p| p == :manage_organisations }
    end
  end
end
