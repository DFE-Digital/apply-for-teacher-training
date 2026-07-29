require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncSiteAndCourseOptionWorker do
  let(:uuid) { SecureRandom.uuid }
  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }
  let(:site_code) { 'A' }
  let(:api_site) { { 'id' => '11299324', 'type' => 'locations', 'attributes' => { 'code' => site_code, 'urn' => '102128', 'latitude' => 51.60120434452688, 'longitude' => -0.135813951192309, 'postcode' => 'N22 7UT', 'region_code' => 'london', 'uuid' => uuid, 'name' => 'Rhodes Avenue Primary School', 'city' => 'London', 'county' => '', 'street_address_1' => 'Rhodes Avenue', 'street_address_2' => '', 'street_address_3' => '' } } }
  let(:job) {
    described_class.new.perform(
      api_site,
      'full_time',
      ['full_time'],
      course.id,
      provider,
      'open',
    )
  }

  describe '#perform' do
    it 'creates site and course option' do
      expect { job }.to change { course.sites.count }.from(0).to(1)
      .and change { course.course_options.count }.from(0).to(1)
    end

    context 'site already exists' do
      let!(:old_site) { create(:site, provider:, uuid:, code: 'Old') }

      it 'updates existing site and does not create new one' do
        expect { job }.not_to(change { Site.count })
        found_site = Site.find_by(uuid:)

        expect(found_site).to eq old_site
        expect(found_site.code).to eq site_code
      end

      context 'course options already exist' do
        let!(:course_option_1) { create(:course_option, :full_time, site: old_site, course:) }
        let!(:course_option_2) { create(:course_option, :part_time, site: old_site, course:) }

        it 'leaves the existing course options unchanged' do
          expect { job }.not_to change(CourseOption, :count)
          expect(Site.find_by(uuid:).course_options).to eq [course_option_1, course_option_2]
        end
      end
    end

    context 'when the site does not already exist' do
      it 'saves a new site in the db' do
        expect { job }.to change { course.sites.count }.from(0).to(1)
        .and change { course.course_options.count }.from(0).to(1)
        site = Site.find_by(uuid:)
        expect(site.course_options).not_to be_empty
        expect(site.course_options.pluck(:study_mode)).to match_array %w[full_time]
      end
    end
  end
end
