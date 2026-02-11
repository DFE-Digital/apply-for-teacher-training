module SupportInterface
  class ConfigureServiceBannerForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :banner_header
    attribute :banner_content

    validates :banner_header, presence: true
    validates :banner_content, presence: true, length: { maximum: 400 }
  end
end
