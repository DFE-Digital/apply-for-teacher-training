module ProviderInterface
  class ProviderUserForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :first_name, :last_name, :provider_user, :current_provider_user
    attr_writer :provider_ids
    attr_reader :email_address

    validates :email_address, :first_name, :last_name, presence: true
    validates :email_address, email: true
    validates :provider_ids, presence: true
    validate :permitted_providers

    def build
      @provider_user = existing_provider_user ? build_from_existing_user : build_new_user

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
        provider_ids: provider_user.provider_ids,
      )
    end

    def provider_ids
      return [] unless @provider_ids

      @provider_ids.reject(&:blank?).map(&:to_i)
    end

    def available_providers
      @available_providers ||= ProviderOptionsService.new(current_provider_user).providers_with_manageable_users
    end

  private

    def build_new_user
      return unless valid?

      provider_user ||= ProviderUser.new
      provider_user.first_name = first_name
      provider_user.last_name = last_name
      provider_user.email_address = email_address
      provider_user.provider_ids = provider_ids
      provider_user
    end

    def build_from_existing_user
      @first_name = existing_provider_user.first_name
      @last_name = existing_provider_user.last_name
      @email_address = existing_provider_user.email_address

      existing_provider_user.provider_ids += provider_ids
      existing_provider_user
    end

    def existing_provider_user
      @existing_provider_user ||= ProviderUser.find_by(email_address: email_address)
    end

    def permitted_providers
      return unless provider_ids.any?
      return if provider_ids_valid?

      errors.add(:provider_ids, 'Insufficient permissions to manage users for this provider')
    end

    def provider_ids_valid?
      (provider_ids & available_providers.pluck(:id)) == provider_ids
    end
  end
end
