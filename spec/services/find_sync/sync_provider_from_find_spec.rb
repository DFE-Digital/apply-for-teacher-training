require 'rails_helper'

RSpec.describe FindSync::SyncProviderFromFind, sidekiq: true do
  include FindAPIHelper

  describe '.call' do
    context 'ingesting a brand new provider' do
      it 'just creates the provider without any courses' do
        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

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

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

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

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

        course_option = CourseOption.last
        expect(course_option.course.provider.code).to eq 'ABC'
        expect(course_option.course.code).to eq '9CBA'
        expect(course_option.course.exposed_in_find).to be true
        expect(course_option.course.recruitment_cycle_year).to eql stubbed_recruitment_cycle_year
        expect(course_option.course.description).to eq 'PGCE with QTS full time'
        expect(course_option.course.start_date).to eq Time.zone.local(stubbed_recruitment_cycle_year, 10, 31)
        expect(course_option.course.course_length).to eq 'OneYear'
        expect(course_option.course.age_range).to eq '4 to 8'
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

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

        course_option = CourseOption.last
        expect(course_option.course.provider.code).to eq 'ABC'
        expect(course_option.course.code).to eq '9CBA'
        expect(course_option.course.exposed_in_find).to be true
        expect(course_option.course.recruitment_cycle_year).to eql stubbed_recruitment_cycle_year
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
        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        expect(CourseOption.count).to eq 1
        CourseOption.first.update!(vacancy_status: 'no_vacancies')

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        expect(CourseOption.count).to eq 1
        expect(CourseOption.first.vacancy_status).to eq 'vacancies'
      end

      it 'correctly updates withdrawn attribute for an existing course' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: '9CBA',
          content_status: 'withdrawn',
        )
        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        expect(CourseOption.count).to eq 1
        Course.first.update!(withdrawn: false)

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        expect(Course.first.withdrawn).to eq true
      end

      it 'correctly handles accredited providers' do
        stub_find_api_provider_200_with_accredited_provider(
          provider_code: 'ABC',
          course_code: '9CBA',
          study_mode: 'full_time',
          accredited_provider_code: 'DEF',
          accredited_provider_name: 'Test Accredited Provider',
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

        course_option = CourseOption.last
        expect(course_option.course.accredited_provider.code).to eq 'DEF'
        expect(course_option.course.accredited_provider.name).to eq 'Test Accredited Provider'
      end

      it 'correctly creates provider relationships' do
        stub_find_api_provider_200_with_accredited_provider(
          provider_code: 'ABC',
          course_code: '9CBA',
          study_mode: 'full_time',
          accredited_provider_code: 'DEF',
          accredited_provider_name: 'Test Accredited Provider',
        )

        expect {
          described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        }.to change(ProviderRelationshipPermissions, :count).by(1)

        permissions = ProviderRelationshipPermissions.last
        expect(permissions.ratifying_provider.code).to eq('DEF')
        expect(permissions.training_provider.code).to eq('ABC')
        expect(permissions.training_provider_can_view_safeguarding_information).to be false
        expect(permissions.ratifying_provider_can_view_safeguarding_information).to be false
      end

      it 'does not create provider relationships for self ratifying providers' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: '9CBA',
          findable: true,
        )

        expect {
          described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        }.not_to change(ProviderRelationshipPermissions, :count)
      end

      it 'does not create provider relationships when the course accredited_provider attribute points back to the same provider' do
        stub_find_api_provider_200_with_accredited_provider(
          provider_code: 'ABC',
          course_code: '9CBA',
          accredited_provider_code: 'ABC',
          findable: true,
        )

        expect {
          described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        }.not_to change(ProviderRelationshipPermissions, :count)
      end

      it 'stores full_time/part_time information within courses' do
        stub_find_api_provider_200_with_accredited_provider(
          provider_code: 'ABC',
          course_code: '9CBA',
          study_mode: 'full_time_or_part_time',
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

        course = Provider.find_by_code('ABC').courses.find_by_code('9CBA')
        expect(course.study_mode).to eq 'full_time_or_part_time'
      end

      it 'creates the correct number of course_options for sites and study_mode' do
        stub_find_api_provider_200_with_multiple_sites(
          provider_code: 'ABC',
          course_code: '9CBA',
          study_mode: 'full_time_or_part_time',
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

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

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

        expect(@existing_provider.reload.region_code).to eq 'north_west'
      end

      it 'correctly handles existing course options with invalid sites' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: '9CBA',
          site_code: 'A',
          findable: true,
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

        expect(Course.count).to eq 1
        expect(CourseOption.count).to eq 1

        course = Course.first
        valid_course_option = course.course_options.first

        invalid_site_one = create(:site, provider: course.provider, code: 'B')
        invalid_site_two = create(:site, provider: course.provider, code: 'C')
        invalid_site_three = create(:site, provider: course.provider, code: 'D')
        invalid_course_option_one = create(:course_option, course: course, site: invalid_site_one)
        invalid_course_option_two = create(:course_option, course: course, site: invalid_site_two)
        invalid_course_option_three = create(:course_option, course: course, site: invalid_site_three)

        create(:application_choice, course_option: invalid_course_option_two)
        create(:application_choice, course_option: valid_course_option, offered_course_option: invalid_course_option_three)

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

        expect(CourseOption.exists?(invalid_course_option_one.id)).to eq false
        expect(invalid_course_option_two.reload).not_to be_site_still_valid
        expect(invalid_course_option_three.reload).not_to be_site_still_valid
        expect(valid_course_option.reload).to be_site_still_valid
      end

      it 'correctly updates subject_codes' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: '9CBA',
          findable: true,
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        course_option = CourseOption.last

        expect(course_option.course.subject_codes).to eq(%w[08])
      end

      # These fields are not present in the Find API yet, but will be soon
      # Our code should set them to nil at first, then the correct values
      # once they are populated
      it 'correctly updates qualifications and program_type when they are not present' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: '9CBA',
          findable: true,
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        course_option = CourseOption.last

        expect(course_option.course.qualifications).to be_nil
        expect(course_option.course.program_type).to be_nil
      end

      it 'correctly updates qualifications when qualifications are present' do
        stub_find_api_provider_200_with_qualifications_and_program_type(
          provider_code: 'ABC',
          course_code: '9CBA',
          findable: true,
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        course_option = CourseOption.last

        expect(course_option.course.qualifications).to eq(%w[PG PF])
      end

      it 'correctly updates program_type when program_type is present' do
        stub_find_api_provider_200_with_qualifications_and_program_type(
          provider_code: 'ABC',
          course_code: '9CBA',
          findable: true,
          program_type: 'SD',
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        course_option = CourseOption.last

        # the enum field converts the value from the short code to the expanded value
        expect(course_option.course.program_type).to eq('school_direct_training_programme')
      end
    end

    context 'ingesting a provider when it existed in the previous recruitment cycle' do
      before do
        set_stubbed_recruitment_cycle_year!(2020)
        @existing_provider = create :provider, code: 'ABC', sync_courses: true

        stub_find_api_provider_200(provider_code: 'ABC', course_code: '9CBA', findable: true)
        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: 2020)

        set_stubbed_recruitment_cycle_year!(2021)
      end

      it 'creates separate courses for the courses in this cycle' do
        expect(Course.count).to eq 1

        stub_find_api_provider_200(provider_code: 'ABC', course_code: '9CBA', findable: true)
        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: 2021)

        expect(Course.count).to eq 2
      end

      it 'carries over the previous course’s open_on_apply status the first time it appears in the new cycle but not the second time' do
        existing_course = Course.find_by(recruitment_cycle_year: 2020)
        existing_course.update(open_on_apply: true)

        stub_find_api_provider_200(provider_code: 'ABC', course_code: '9CBA', findable: true)
        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: 2021)

        new_course = Course.find_by(recruitment_cycle_year: 2021)
        expect(new_course).to be_open_on_apply

        new_course.update(open_on_apply: false)

        stub_find_api_provider_200(provider_code: 'ABC', course_code: '9CBA', findable: true)
        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: 2021)

        expect(new_course.reload).not_to be_open_on_apply
      end
    end
  end
end
