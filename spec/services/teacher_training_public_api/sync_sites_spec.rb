require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncSites, :sidekiq do
  include TeacherTrainingPublicAPIHelper

  describe 'course study modes' do
    context 'when the course has no course options' do
      let(:course) { create(:course) }

      it 'returns both study modes if the course supports both study modes' do
        course.full_time_or_part_time!

        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time part_time]
      end

      it 'returns one study mode if the course only supports one' do
        course.full_time!

        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time]
      end
    end

    context 'when the course has existing course options with uniform study modes' do
      let(:course) do
        create(:course, :part_time) do |course|
          course.course_options = [
            create(:course_option, :part_time, course:),
            create(:course_option, :part_time, course:),
            create(:course_option, :part_time, course:),
          ]
        end
      end

      it 'returns the existing study mode' do
        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[part_time]
      end

      it 'returns both study modes if the course changes to support both study modes' do
        course.full_time_or_part_time!

        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time part_time]
      end

      it 'returns both study modes if the course changes from one to the other' do
        course.full_time!

        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time part_time]
      end
    end

    context 'when the course has existing course options with a mix of study modes' do
      let(:course) do
        create(:course, :with_both_study_modes) do |course|
          course.course_options = [
            create(:course_option, :part_time, course:),
            create(:course_option, :part_time, course:),
            create(:course_option, :full_time, course:),
          ]
        end
      end

      it 'returns both study modes' do
        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time part_time]
      end

      it 'returns both study modes even if the course changes to a specific one' do
        course.full_time!

        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time part_time]
      end
    end
  end

  describe 'syncing sites' do
    let(:provider_from_api) { fake_api_provider({ code: 'ABC' }) }
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
    let(:perform_job) do
      described_class.new.perform(provider.id,
                                  RecruitmentCycle.current_year,
                                  course.id,
                                  'open',
                                  false)
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
      allow(Sentry).to receive(:capture_exception)
    end

    context 'when the site exists' do
      let!(:existing_site) { create(:site, provider:, uuid:, code: 'Old') }

      it 'does not create a new record' do
        expect { perform_job }.not_to change(Site, :count)
      end

      it 'updates the site in the db' do
        perform_job
        site = Site.find_by(uuid:)
        expect(site).to eq existing_site
        expect(site.code).to eq site_code
      end

      context 'course options already exist' do
        let!(:course_option_1) { create(:course_option, site: existing_site, course:, study_mode: 'full_time') }
        let!(:course_option_2) { create(:course_option, site: existing_site, course:, study_mode: 'part_time') }

        it 'updates existing course options' do
          expect { perform_job }.not_to change(CourseOption, :count)
          expect(Site.find_by(uuid:).course_options).to eq [course_option_1, course_option_2]
        end
      end

      context 'course options do not already exist' do
        it 'creates corresponding course options' do
          expect { perform_job }.to change(CourseOption, :count).by(2)
          site = Site.find_by(uuid:)
          expect(site.course_options).not_to be_empty
          expect(site.course_options.pluck(:study_mode)).to eq %w[full_time part_time]
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
        expect(site.course_options.pluck(:study_mode)).to eq %w[full_time part_time]
      end
    end

    context 'when course changes from both study modes to just part time' do
      context 'and the course already has full time and part time course options' do
        it 'deletes only full time course options' do
          create(:course_option, course:, study_mode: :full_time)
          create(:course_option, course:, study_mode: :part_time)
          course.update(study_mode: :part_time)
          expect { perform_job }.to change(CourseOption, :count).by(-1)
          expect(course.course_options.full_time.any?).to eq false
          expect(course.course_options.part_time.count).to eq 1
        end
      end
    end

    context 'when course changes from both study modes to just full time' do
      context 'and the course already has full time and part time course options' do
        it 'deletes only part time options' do
          create(:course_option, course:, study_mode: :full_time)
          create(:course_option, course:, study_mode: :part_time)
          course.update(study_mode: :full_time)

          expect { perform_job }.to change(CourseOption, :count).by(-1)
          expect(course.course_options.part_time.any?).to eq false
          expect(course.course_options.full_time.count).to eq 1
        end
      end
    end

    context 'when course is closed' do
      it 'updates corresponding course options to no vacancies' do
        described_class.new.perform(
          provider.id,
          RecruitmentCycle.current_year,
          course.id,
          'closed',
          true,
        )
        expect(
          course.reload.course_options.pluck(:vacancy_status),
        ).to eq %w[no_vacancies no_vacancies]
      end
    end
  end

  context 'ingesting an existing site when incremental_sync is off' do
    let(:incremental_sync) { false }
    let(:provider_from_api) { fake_api_provider({ code: 'ABC' }) }
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

      allow(Sentry).to receive(:capture_exception)
    end

    around do |example|
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'production' do
        example.run
      end
    end

    it 'raises a FullSync error' do
      described_class.new.perform(provider.id,
                                  RecruitmentCycle.current_year,
                                  course.id,
                                  'open',
                                  false)

      expect(Sentry).to have_received(:capture_exception)
        .with(TeacherTrainingPublicAPI::FullSyncUpdateError.new(%(site and course_option have been updated\n[#{site_a.id}, {"address_line3"=>["#{site_a.address_line3}", ""]}],\n[#{site_b.id}, {"address_line3"=>["#{site_b.address_line3}", ""]}])))
    end
  end

  describe '#handle_course_options_with_reinstated_sites' do
    context 'when site was previously withdrawn' do
      let(:course) do
        create(:course, :part_time) do |course|
          course.course_options = [
            create(:course_option, :part_time, course:, site_still_valid: true),
            create(:course_option, :part_time, course:, site_still_valid: true),
            create(:course_option, :part_time, course:, site_still_valid: false),
          ]
        end
      end

      it 'sets `site_still_valid` to false on any course options with missing sites' do
        described_class.new.tap do |sync_sites|
          sync_sites.instance_variable_set(:@course, course)
        end.send(
          :handle_course_options_with_reinstated_sites,
          course.course_options.map { |course_option| Struct.new(:uuid).new(course_option.site.uuid) },
        )
        course_options = course.course_options.reload
        expect(course_options[0].site_still_valid).to be(true)
        expect(course_options[1].site_still_valid).to be(true)
        expect(course_options[2].site_still_valid).to be(true)
      end
    end
  end
end
