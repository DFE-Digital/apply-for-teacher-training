class RemoveServiceBannerFeatureFlag < ActiveRecord::Migration[8.0]
  TIMESTAMP = 20260225120746
  MANUAL_RUN = false

  def change
    Feature.where(name: 'service_information_banner').delete_all
  end
end
