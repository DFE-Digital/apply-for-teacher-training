module ProviderInterface
  class APITokenForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :description
    attribute :provider

    validates :description, presence: true
    validates :provider, presence: true

    def save!
      return false unless valid?

      VendorAPIToken.create_with_random_token!(provider:, description:)
    end
  end
end
