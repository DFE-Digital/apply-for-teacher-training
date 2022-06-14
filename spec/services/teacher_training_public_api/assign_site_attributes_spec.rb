require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::AssignSiteAttributes do
  let(:site) { described_class.new(site_from_api, provider).call }
  let(:uuid) { Faker::Internet.uuid }

  let(:provider) { create(:provider) }
  let(:site_from_api) do
    Struct.new(
      :code, :name, :street_address_1, :street_address_2, :city,
      :county, :region_code, :postcode, :latitude, :longitude,
      :uuid
    ).new(
      'FALAFEL', 'School of Falafel', 'Tahini Road', 'Chickpea on Sea', 'Olivopolis',
      'Cuminia', 'south_east', 'SS0 7JS', '51.5371634', '0.69922', uuid
    )
  end

  it 'assigns attributes' do
    expect(site.name).to eq site_from_api.name
    expect(site.address_line1).to eq site_from_api.street_address_1
    expect(site.address_line2).to eq site_from_api.street_address_2
    expect(site.address_line3).to eq site_from_api.city
    expect(site.address_line4).to eq site_from_api.county
    expect(site.postcode).to eq site_from_api.postcode
    expect(site.region).to eq site_from_api.region_code
    expect(site.latitude).to eq site_from_api.latitude.to_f
    expect(site.longitude).to eq site_from_api.longitude.to_f
    expect(site.uuid).to eq site_from_api.uuid
  end
end
