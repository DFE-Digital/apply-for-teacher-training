require 'rails_helper'

RSpec.describe DataMigrations::CreateMissingTempSites do
  describe 'creating TempSites not included in API sync' do
    let(:provider) { create(:provider) }
    let(:course) { create(:course, provider: provider, recruitment_cycle_year: 2022) }
    let!(:site1) { create(:site, code: 'falafel', provider: provider) }

    context 'course option already has a temp site' do
      let(:temp_site) { create(:temp_site, code: 'falafel', provider: provider) }

      before { create(:course_option, site: site1, temp_site: temp_site, course: course) }

      it 'does not create new temp site' do
        expect { described_class.new.change }.not_to(change { TempSite.count })
      end
    end

    context 'course option does not already have a temp site' do
      subject(:new_temp_site) do
        described_class.new.change
        TempSite.find_by(code: site1.code, provider: provider)
      end

      let!(:course_option) { create(:course_option, site: site1, course: course) }

      it 'creates missing temp site' do
        expect(new_temp_site).to be_present
      end

      it 'assigns properties from site' do
        expect(new_temp_site.name).to eq site1.name
        expect(new_temp_site.address_line1).to eq site1.address_line1
        expect(new_temp_site.address_line2).to eq site1.address_line2
        expect(new_temp_site.address_line3).to eq site1.address_line3
        expect(new_temp_site.address_line4).to eq site1.address_line4
        expect(new_temp_site.postcode).to eq site1.postcode
        expect(new_temp_site.latitude).to eq site1.latitude
        expect(new_temp_site.longitude).to eq site1.longitude
        expect(new_temp_site.region).to eq site1.region
      end

      it 'generates a uuid and sets uuid_generated_by_apply' do
        expect(new_temp_site.uuid).to be_present
        expect(new_temp_site).to be_uuid_generated_by_apply
      end

      it 'attaches temp site to course option' do
        expect(new_temp_site.course_options).to eq [course_option]
      end
    end

    context 'course option site has matching temp site for a previous cycle' do
      let(:old_course) { create(:course, provider: provider, recruitment_cycle_year: 2021) }
      let!(:course_option) { create(:course_option, site: site1, course: course) }
      let!(:old_course_option) { create(:course_option, site: site1, course: old_course) }
      let(:old_temp_site) { create(:temp_site, code: site1.code, provider: provider) }

      before { old_temp_site.course_options << old_course_option }

      it 'creates a new temp site' do
        expect { described_class.new.change }.to change { TempSite.count }.by(1)
      end

      it 'attaches new temp site to course option' do
        described_class.new.change
        new_temp_site = TempSite.last
        expect(new_temp_site.course_options).to eq [course_option]
        expect(old_temp_site.course_options).to eq [old_course_option]
      end
    end
  end
end
