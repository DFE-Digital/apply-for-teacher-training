module SupportInterface
  class ShowServiceBannerForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :show_service_banner

    validates :show_service_banner, presence: true

    def show_service_banner?
      show_service_banner == 'yes'
    end
  end
end
