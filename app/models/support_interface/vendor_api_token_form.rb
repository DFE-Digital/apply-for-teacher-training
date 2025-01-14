module SupportInterface
  class VendorAPITokenForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :provider_id

    validates :provider_id, presence: true

    def providers_for_select = Provider.all

    def save
      return false unless valid?

      provider = Provider.find(provider_id)
      VendorAPIToken.create_with_random_token!(provider: provider)
    end
  end
end
