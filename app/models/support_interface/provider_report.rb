module SupportInterface
  class ProviderReport
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :provider_id
    validates :provider_id, presence: true
  end
end
