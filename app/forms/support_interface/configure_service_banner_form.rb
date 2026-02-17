module SupportInterface
  class ConfigureServiceBannerForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :header
    attribute :body
    attribute :interface

    attr_accessor :banner

    validates :header, presence: true
    validates :body, length: { maximum: 400 }

    def save
      return false if invalid?

      if banner.present?
        banner.update!(
          interface: interface.downcase,
          header:,
          body:,
          status: 'draft',
        )
      else
        ServiceBanner.create!(
          interface: interface.downcase,
          header:,
          body:,
          status: 'draft',
        )
      end
    end
  end
end
