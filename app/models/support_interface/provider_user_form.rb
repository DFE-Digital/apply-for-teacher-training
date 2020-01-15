module SupportInterface
  class ProviderUserForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :email_address, :provider_ids, :provider_user

    validates_presence_of :email_address
    validates :provider_ids, presence: true

    def save
      return unless valid?

      @provider_user ||= ProviderUser.new

      @provider_user.update!(
        email_address: email_address,
        provider_ids: provider_ids,
      )
    end

    def available_providers
      @available_providers ||= Provider.order(name: :asc)
    end

    def persisted?
      provider_user && provider_user.persisted?
    end

    def self.from_provider_user(provider_user)
      new(
        provider_user: provider_user,
        email_address: provider_user.email_address,
        provider_ids: provider_user.provider_ids,
      )
    end
  end
end
