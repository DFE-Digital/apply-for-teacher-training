module ProviderInterface
  class APITokenForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :description

    validates :description, presence: true

    def initialize(attributes = {}, provider:)
      @provider = provider
      super(attributes)
    end

    def save!
      return false unless valid?

      VendorAPIToken.create_with_random_token!({ description: }, provider: @provider)
    end
  end
end
