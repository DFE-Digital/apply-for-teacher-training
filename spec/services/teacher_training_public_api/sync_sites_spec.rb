require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncSites, :sidekiq do
  include TeacherTrainingPublicAPIHelper

  describe 'syncing sites' do
    let(:provider) { create(:provider) }
    let(:course) { create(:course, :with_both_study_modes, provider:) }
    let(:uuid) { SecureRandom.uuid }
    let(:site_code) { 'Site A' }
    let(:site_details) do
      { name: 'St Bernards High School',
        address_line1: 'Milton Road',
        address_line2: 'Westcliff on Sea',
        region: 'south_east',
        postcode: 'SS0 7JS',
        latitude: '51.5371634',
        longitude: ' 0.69922',
        uuid: }
    end
    let(:incremental_sync) { false }
    let(:perform_job) do
      described_class.new.perform(provider.id,
                                  current_year,
                                  course.id,
                                  'open',
                                  incremental_sync)
    end

    before do
      stub_teacher_training_api_course(provider_code: provider.code,
                                       course_code: course.code,
                                       specified_attributes: { provider_code: provider.code })

      stub_teacher_training_api_sites(provider_code: provider.code,
                                      course_code: course.code,
                                      specified_attributes: [
                                        {
                                          provider_code: provider.code,
                                          code: site_code,
                                          uuid:,
                                        },
                                      ])
    end

    context 'when the site exists' do
      let!(:site) { create(:site, provider:, uuid:, code: 'Old') }

      it 'does not create a new record' do
        expect { perform_job }.not_to change(Site, :count)
      end

      it 'updates the site in the db' do
        perform_job
        found_site = Site.find_by(uuid:)
        expect(found_site).to eq site
        expect(found_site.code).to eq site_code
      end

      context 'course options already exist' do
        let!(:course_option_1) { create(:course_option, :full_time, site:, course:) }
        let!(:course_option_2) { create(:course_option, :part_time, site:, course:) }

        it 'leaves the existing course options unchanged' do
          expect { perform_job }.not_to change(CourseOption, :count)
          expect(Site.find_by(uuid:).course_options).to eq [course_option_1, course_option_2]
        end
      end

      context 'course options do not already exist' do
        it 'creates corresponding course options' do
          expect { perform_job }.to change(CourseOption, :count).by(2)
          site = Site.find_by(uuid:)
          expect(site.course_options).not_to be_empty
          expect(site.course_options.pluck(:study_mode)).to match_array %w[full_time part_time]
        end
      end
    end

    context 'when the site does not already exist' do
      it 'saves a new site in the db' do
        perform_job
        expect(Site.find_by(uuid:)).to be_present
      end

      it 'creates corresponding course options' do
        expect { perform_job }.to change(CourseOption, :count).by(2)
        site = Site.find_by(uuid:)
        expect(site.course_options).not_to be_empty
        expect(site.course_options.pluck(:study_mode)).to match_array %w[full_time part_time]
      end
    end

    context 'when existing site is not in api response' do
      let(:obsolete_uuid) { '8ea3003b-b2f8-49a9-96e2-83de1066d25f' }
      let!(:obsolete_site) { create(:site, provider:, uuid: obsolete_uuid, code: 'Invalid') }
      let!(:course_option) { create(:course_option, course:, site: obsolete_site) }

      it 'deletes course options without an application choice' do
        perform_job
        expect(CourseOption.joins(:site).find_by(sites: { uuid: obsolete_uuid })).not_to be_present
      end

      context 'when application exists for course option marked for deletion' do
        before { create(:application_choice, course_option:) }

        it 'changes site_still_valid from true to false' do
          expect { perform_job }.to change { course_option.reload.site_still_valid }.from(true).to(false)
        end
      end

      context 'when application exists for current course option marked for deletion' do
        let(:other_course) { create(:course, :with_a_course_option, provider:) }

        before { create(:application_choice, course_option: other_course.course_options.first, current_course_option: course_option) }

        it 'changes site_still_valid from true to false' do
          expect { perform_job }.to change { course_option.reload.site_still_valid }.from(true).to(false)
        end
      end
    end

    context 'when course changes from both study modes to just full_time' do
      let(:course) { create(:course, :full_time, provider:) }
      let(:site) { create(:site, provider:, uuid:, code: 'Old') }
      let!(:full_time_course_option) { create(:course_option, :full_time, site:, course:) }
      let!(:part_time_course_option) { create(:course_option, :part_time, site:, course:) }

      context 'no applications created for part time course option' do
        it 'deletes part_time course option' do
          expect { perform_job }.to change { CourseOption.exists?(part_time_course_option.id) }.from(true).to(false)
        end
      end

      context 'when application exists for part_time course option' do
        before { create(:application_choice, course_option: part_time_course_option) }

        it 'changes site_still_valid from true to false' do
          expect { perform_job }.to change { part_time_course_option.reload.site_still_valid }.from(true).to(false)
        end

        it 'changes vacancy_status from "vacancies" to "no_vacancies"' do
          expect { perform_job }.to change { part_time_course_option.reload.vacancy_status }.from('vacancies').to('no_vacancies')
        end
      end
    end

    context 'when course is closed', :with_audited do
      let!(:site) { create(:site, provider:, uuid:, code: 'Old') }
      let!(:full_time_course_option) { create(:course_option, :full_time, site:, course:) }
      let!(:part_time_course_option) { create(:course_option, :part_time, site:, course:) }

      it 'updates corresponding course options to no vacancies' do
        described_class.new.perform(
          provider.id,
          current_year,
          course.id,
          'closed',
          true,
        )
        expect(
          course.reload.course_options.pluck(:vacancy_status),
        ).to eq %w[no_vacancies no_vacancies]

        expect(full_time_course_option.audits.last.audited_changes).to eq({ 'vacancy_status' => %w[vacancies no_vacancies] })
        expect(part_time_course_option.audits.last.audited_changes).to eq({ 'vacancy_status' => %w[vacancies no_vacancies] })
      end
    end
  end

  context 'ingesting an existing site when incremental_sync is off' do
    let(:incremental_sync) { false }
    let(:provider) { create(:provider) }
    let(:course) { create(:course, provider:) }
    let(:site_uuid_1) { SecureRandom.uuid }
    let(:site_uuid_2) { SecureRandom.uuid }
    let(:shared_site_details) do
      { name: 'St Bernards High School',
        address_line1: 'Milton Road',
        address_line2: 'Westcliff on Sea',
        region: 'south_east',
        postcode: 'SS0 7JS',
        latitude: '51.5371634',
        longitude: ' 0.69922' }
    end
    let!(:site_a) do
      create(:site, { provider:,
                      code: 'Site A',
                      uuid: site_uuid_1,
                      course_options: course.course_options }.merge!(shared_site_details))
    end
    let!(:site_b) do
      create(:site, { provider:,
                      code: 'Site B',
                      uuid: site_uuid_2,
                      course_options: course.course_options }.merge!(shared_site_details))
    end

    before do
      stub_teacher_training_api_course(provider_code: provider.code,
                                       course_code: course.code,
                                       specified_attributes: { provider_code: provider.code })
      stub_teacher_training_api_sites(provider_code: provider.code,
                                      course_code: course.code,
                                      specified_attributes: [
                                        {
                                          provider_code: provider.code,
                                          code: 'Site A',
                                          uuid: site_uuid_1,
                                        },
                                        {
                                          provider_code: provider.code,
                                          code: 'Site B',
                                          uuid: site_uuid_2,
                                        },
                                      ])
    end

    around do |example|
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'production' do
        example.run
      end
    end

    it 'Updates the records' do
      original_site_a_address_line3 = site_a.address_line3
      original_site_b_address_line3 = site_b.address_line3

      described_class.new.perform(provider.id,
                                  current_year,
                                  course.id,
                                  'open',
                                  incremental_sync)

      expect(original_site_a_address_line3).not_to eq site_a.reload.address_line3
      expect(original_site_b_address_line3).not_to eq site_b.reload.address_line3
    end
  end
end
