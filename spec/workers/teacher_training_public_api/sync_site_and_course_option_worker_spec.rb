require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncSiteAndCourseOptionWorker do
  let(:uuid) { SecureRandom.uuid }
  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }
  let(:site_code) { 'A' }
  let(:api_sites) do
    [
      [{ 'id' => '11222249', 'type' => 'locations', 'relationships' => { 'location_status' => { 'data' => { 'type' => 'location_statuses', 'id' => '22360124' } } }, 'attributes' => { 'code' => 'Site A', 'latitude' => 51.5371634, 'longitude' => 0.69922, 'postcode' => 'SS0 7JS', 'region_code' => 'south_east', 'uuid' => 'c67f69ab-5c2c-49de-ac8b-1f04d562148f', 'name' => 'St Bernards High School', 'city' => '', 'county' => '', 'street_address_1' => 'Milton Road', 'street_address_2' => 'Westcliff on Sea' } }, 'full_time'],
      [{ 'id' => '11222249', 'type' => 'locations', 'relationships' => { 'location_status' => { 'data' => { 'type' => 'location_statuses', 'id' => '22360124' } } }, 'attributes' => { 'code' => 'Site A', 'latitude' => 51.5371634, 'longitude' => 0.69922, 'postcode' => 'SS0 7JS', 'region_code' => 'south_east', 'uuid' => 'c67f69ab-5c2c-49de-ac8b-1f04d562148f', 'name' => 'St Bernards High School', 'city' => '', 'county' => '', 'street_address_1' => 'Milton Road', 'street_address_2' => 'Westcliff on Sea' } }, 'part_time'],
    ]
  end
  let(:job) {
    described_class.new.perform(
      api_sites,
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
