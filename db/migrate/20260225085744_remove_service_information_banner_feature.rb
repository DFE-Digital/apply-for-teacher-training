class RemoveServiceInformationBannerFeature < ActiveRecord::Migration[8.0]
  def up
    Feature.delete(3)
  end

  def down
    Feature.create!(
      id: 3,
      name: 'service_information_banner',
      active: false,
    )
  end
end
