require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::AssignTempSiteAttributes do
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
  end

  context 'when the provider has the temp site' do
    let!(:temp_site) { create(:temp_site, provider: provider, uuid: uuid) }

    it 'finds a TempSite' do
      expect(site.uuid).to eq temp_site.uuid
    end
  end

  context 'when the provider does not have the temp site' do
    it 'creates a TempSite' do
      expect(site.uuid).to eq site_from_api.uuid
    end
  end

  context 'api site uuid is nil' do
    let(:uuid) { nil }

    it 'creates a TempSite and sets uuid_generated_by_apply' do
      expect(site.uuid).not_to be_nil
      expect(site).to be_uuid_generated_by_apply
    end
  end
end
