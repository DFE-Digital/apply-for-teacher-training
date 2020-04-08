require 'rails_helper'

RSpec.describe SyncProviderFromFind do
  include FindAPIHelper

  describe '.call' do
    context 'ingesting a brand new provider' do
      it 'just creates the provider without any courses' do
        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

        provider = Provider.find_by_code('ABC')
        expect(provider).to be_present
        expect(provider.courses).to be_blank
      end
    end

    context 'ingesting an existing provider not configured to sync courses' do
      before do
        @existing_provider = create :provider, code: 'ABC', sync_courses: false, name: 'Foobar College'
      end

      it 'correctly updates the provider but does not import any courses' do
        stub_find_api_provider_200(provider_code: 'ABC', findable: true)

        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

        expect(@existing_provider.reload.courses).to be_blank
        expect(@existing_provider.reload.name).to eq 'ABC College'
      end
    end

    context 'ingesting an existing provider configured to sync courses, sites and course_options' do
      before do
        @existing_provider = create :provider, code: 'ABC', sync_courses: true
      end

      it 'correctly creates all the entities' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: '9CBA',
          findable: true,
        )

        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

        course_option = CourseOption.last
        expect(course_option.course.provider.code).to eq 'ABC'
        expect(course_option.course.code).to eq '9CBA'
        expect(course_option.course.exposed_in_find).to be true
        expect(course_option.course.recruitment_cycle_year).to be FindAPI::RECRUITMENT_CYCLE_YEAR
        expect(course_option.course.description).to eq 'PGCE with QTS full time'
        expect(course_option.course.start_date).to eq Time.zone.local(2020, 10, 31)
        expect(course_option.course.course_length).to eq 'OneYear'
        expect(course_option.site.name).to eq 'Main site'
        expect(course_option.site.address_line1).to eq 'Gorse SCITT'
        expect(course_option.site.address_line2).to eq 'C/O The Bruntcliffe Academy'
        expect(course_option.site.address_line3).to eq 'Bruntcliffe Lane'
        expect(course_option.site.address_line4).to eq 'MORLEY, LEEDS'
        expect(course_option.site.postcode).to eq 'LS27 0LZ'
        expect(course_option.vacancy_status).to eq 'vacancies'
      end

      it 'correctly handles missing address info' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: '9CBA',
          findable: true,
          site_address_line2: nil,
        )

        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

        course_option = CourseOption.last
        expect(course_option.course.provider.code).to eq 'ABC'
        expect(course_option.course.code).to eq '9CBA'
        expect(course_option.course.exposed_in_find).to be true
        expect(course_option.course.recruitment_cycle_year).to be FindAPI::RECRUITMENT_CYCLE_YEAR
        expect(course_option.site.name).to eq 'Main site'
        expect(course_option.site.address_line1).to eq 'Gorse SCITT'
        expect(course_option.site.address_line2).to be_nil
        expect(course_option.site.address_line3).to eq 'Bruntcliffe Lane'
        expect(course_option.site.address_line4).to eq 'MORLEY, LEEDS'
        expect(course_option.site.postcode).to eq 'LS27 0LZ'
      end

      it 'correctly updates vacancy status for any existing course options' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: '9CBA',
          findable: true,
        )
        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')
        expect(CourseOption.count).to eq 1
        CourseOption.first.update!(vacancy_status: 'no_vacancies')

        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')
        expect(CourseOption.count).to eq 1
        expect(CourseOption.first.vacancy_status).to eq 'vacancies'
      end

      it 'correctly handles accredited providers' do
        stub_find_api_provider_200_with_accredited_provider(
          provider_code: 'ABC',
          course_code: '9CBA',
          study_mode: 'full_time',
          accredited_provider_code: 'DEF',
          accredited_provider_name: 'Test Accredited Provider',
        )

        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

        course_option = CourseOption.last
        expect(course_option.course.accredited_provider.code).to eq 'DEF'
        expect(course_option.course.accredited_provider.name).to eq 'Test Accredited Provider'
      end

      it 'stores full_time/part_time information within courses' do
        stub_find_api_provider_200_with_accredited_provider(
          provider_code: 'ABC',
          course_code: '9CBA',
          study_mode: 'full_time_or_part_time',
        )

        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

        course = Provider.find_by_code('ABC').courses.find_by_code('9CBA')
        expect(course.study_mode).to eq 'full_time_or_part_time'
      end

      it 'creates the correct number of course_options for sites and study_mode' do
        stub_find_api_provider_200_with_multiple_sites(
          provider_code: 'ABC',
          course_code: '9CBA',
          study_mode: 'full_time_or_part_time',
        )

        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

        provider = Provider.find_by_code('ABC')
        course_options = provider.courses.find_by_code('9CBA').course_options

        expect(course_options.count).to eq 4
        provider.sites.each do |site|
          modes_for_site = course_options.where(site_id: site.id).pluck(:study_mode)
          expect(modes_for_site).to match_array %w[full_time part_time]
        end
      end

      it 'correctly updates the Provider#region_code' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: '9CBA',
          findable: true,
        )

        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

        expect(@existing_provider.reload.region_code).to eq 'north_west'
      end

      it 'correctly handles existing course options with invalid sites' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: '9CBA',
          site_code: 'A',
          findable: true,
        )
        allow(Raven).to receive(:capture_message)
        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')
        expect(Course.count).to eq 1
        expect(CourseOption.count).to eq 1
        course = Course.first
        valid_course_option = course.course_options.first

        invalid_site_one = create(:site, provider: course.provider, code: 'B')
        invalid_site_two = create(:site, provider: course.provider, code: 'C')
        invalid_course_option_one = create(:course_option, course: course, site: invalid_site_one)
        invalid_course_option_two = create(:course_option, course: course, site: invalid_site_two)
        create(:application_choice, course_option: invalid_course_option_two)
        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

        expect(CourseOption.exists?(invalid_course_option_one.id)).to eq false
        expect(invalid_course_option_two.reload).to be_invalidated_by_find
        expect(valid_course_option.reload).not_to be_invalidated_by_find
        expect(Raven).to have_received(:capture_message).with(/is now invalid/)
      end

      it 'correctly updates subject_codes' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: '9CBA',
          findable: true,
        )

        SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')
        course_option = CourseOption.last

        expect(course_option.course.subject_codes).to eq(%w[08])
      end
    end
  end

  describe 'CourseVacancyStatus#derive' do
    context 'when study_mode is part_time' do
      let(:study_mode) { 'part_time' }

      [
        { description: 'no_vacancies', vacancy_status: :no_vacancies },
        { description: 'both_full_time_and_part_time_vacancies', vacancy_status: :vacancies },
        { description: 'full_time_vacancies', vacancy_status: :no_vacancies },
        { description: 'part_time_vacancies', vacancy_status: :vacancies },
      ].each do |pair|
        it "returns #{pair[:vacancy_status]} when description is #{pair[:description]}" do
          derived_status = SyncProviderFromFind::CourseVacancyStatus.new(
            pair[:description],
            study_mode,
          ).derive

          expect(derived_status).to eq pair[:vacancy_status]
        end
      end

      it 'raises an error when description is an unexpected value' do
        expect {
          SyncProviderFromFind::CourseVacancyStatus.new('foo', study_mode).derive
        }.to raise_error(
          SyncProviderFromFind::CourseVacancyStatus::InvalidFindStatusDescriptionError,
        )
      end
    end

    context 'when study_mode is full_time' do
      let(:study_mode) { 'full_time' }

      [
        { description: 'no_vacancies', vacancy_status: :no_vacancies },
        { description: 'both_full_time_and_part_time_vacancies', vacancy_status: :vacancies },
        { description: 'full_time_vacancies', vacancy_status: :vacancies },
        { description: 'part_time_vacancies', vacancy_status: :no_vacancies },
      ].each do |pair|
        it "returns #{pair[:vacancy_status]} when description is #{pair[:description]}" do
          derived_status = SyncProviderFromFind::CourseVacancyStatus.new(
            pair[:description],
            study_mode,
          ).derive

          expect(derived_status).to eq pair[:vacancy_status]
        end
      end

      it 'raises an error when description is an unexpected value' do
        expect {
          SyncProviderFromFind::CourseVacancyStatus.new('foo', study_mode).derive
        }.to raise_error(
          SyncProviderFromFind::CourseVacancyStatus::InvalidFindStatusDescriptionError,
        )
      end
    end
  end

  describe 'CourseStudyModes#derive' do
    context 'when the course has no course options' do
      let(:course) { create(:course) }

      it 'returns both study modes if the course supports both study modes' do
        course.full_time_or_part_time!

        study_modes = SyncProviderFromFind::CourseStudyModes.new(course).derive
        expect(study_modes).to match_array %w(full_time part_time)
      end

      it 'returns one study mode if the course only supports one' do
        course.full_time!

        study_modes = SyncProviderFromFind::CourseStudyModes.new(course).derive
        expect(study_modes).to match_array %w(full_time)
      end
    end

    context 'when the course has existing course options with uniform study modes' do
      let(:course) do
        create(:course, :part_time) do |course|
          course.course_options = [
            create(:course_option, :part_time, course: course),
            create(:course_option, :part_time, course: course),
            create(:course_option, :part_time, course: course),
          ]
        end
      end

      it 'returns the existing study mode' do
        study_modes = SyncProviderFromFind::CourseStudyModes.new(course).derive
        expect(study_modes).to match_array %w(part_time)
      end

      it 'returns both study modes if the course changes to support both study modes' do
        course.full_time_or_part_time!

        study_modes = SyncProviderFromFind::CourseStudyModes.new(course).derive
        expect(study_modes).to match_array %w(full_time part_time)
      end

      it 'returns both study modes if the course changes from one to the other' do
        course.full_time!

        study_modes = SyncProviderFromFind::CourseStudyModes.new(course).derive
        expect(study_modes).to match_array %w(full_time part_time)
      end
    end

    context 'when the course has existing course options with a mix of study modes' do
      let(:course) do
        create(:course, :with_both_study_modes) do |course|
          course.course_options = [
            create(:course_option, :part_time, course: course),
            create(:course_option, :part_time, course: course),
            create(:course_option, :full_time, course: course),
          ]
        end
      end

      it 'returns both study modes' do
        study_modes = SyncProviderFromFind::CourseStudyModes.new(course).derive
        expect(study_modes).to match_array %w(full_time part_time)
      end

      it 'returns both study modes even if the course changes to a specific one' do
        course.full_time!

        study_modes = SyncProviderFromFind::CourseStudyModes.new(course).derive
        expect(study_modes).to match_array %w(full_time part_time)
      end
    end
  end
end
