require 'rails_helper'

RSpec.describe DataMigrations::CreateMissingTempSites do
  describe 'creating TempSites not included in API sync' do
    let(:provider) { create(:provider) }
    let(:course) { create(:course, provider: provider) }
    let!(:site1) { create(:site, code: 'falafel', provider: provider) }
    let!(:site2) { create(:site, code: 'tabbouleh', provider: provider) }
    let!(:temp_site) { create(:temp_site, code: 'falafel', provider: provider) }

    subject(:new_temp_site) do
      described_class.new.change
      TempSite.find_by(code: 'tabbouleh', provider: provider)
    end

    context 'course options attached to site' do
      let!(:course_option1) { create(:course_option, site: site1, course: course) }
      let!(:course_option2) { create(:course_option, site: site2, course: course) }

      it 'creates missing temp site' do
        expect(new_temp_site).to be_present
      end

      it 'assigns properties from site' do
        expect(new_temp_site.name).to eq site2.name
        expect(new_temp_site.address_line1).to eq site2.address_line1
        expect(new_temp_site.address_line2).to eq site2.address_line2
        expect(new_temp_site.address_line3).to eq site2.address_line3
        expect(new_temp_site.address_line4).to eq site2.address_line4
        expect(new_temp_site.postcode).to eq site2.postcode
        expect(new_temp_site.latitude).to eq site2.latitude
        expect(new_temp_site.longitude).to eq site2.longitude
        expect(new_temp_site.region).to eq site2.region
      end

      it 'generates a uuid and sets uuid_generated_by_apply' do
        expect(new_temp_site.uuid).to be_present
        expect(new_temp_site).to be_uuid_generated_by_apply
      end

      it 'attaches course options to temp site' do
        expect(new_temp_site.course_options).to eq [course_option2]
      end
    end

    context 'no course options attached to site' do
      it 'does not create missing temp site' do
        expect(new_temp_site).not_to be_present
      end
    end
  end
end
