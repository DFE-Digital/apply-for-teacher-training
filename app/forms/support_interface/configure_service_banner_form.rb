module SupportInterface
  class ConfigureServiceBannerForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    attribute :header
    attribute :body
    attribute :interface

    before_validation :normalize_interface_attribute

    INTERFACES = %w[support_console apply manage].freeze

    validates :interface, inclusion: { in: INTERFACES }

    attr_accessor :banner

    validates :header, presence: true
    validates :body, length: { maximum: 400 }

    def save
      return false if invalid?

      if banner.present?
        banner.update!(
          interface: interface,
          header:,
          body:,
          status: 'draft',
        )
      else
        ServiceBanner.create!(
          interface: interface,
          header:,
          body:,
          status: 'draft',
        )
      end
    end

    def normalize_interface_attribute
      self.interface = interface&.strip
    end
  end
end
