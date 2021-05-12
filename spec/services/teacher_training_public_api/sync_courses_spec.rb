require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncCourses, sidekiq: true do
  include TeacherTrainingPublicAPIHelper

  describe '.call' do
    context 'ingesting an existing provider configured to sync courses, sites and course_options' do
      let(:existing_provider) do
        create(:provider, code: 'ABC', sync_courses: true, provider_type: 'scitt', region_code: 'south_west', postcode: 'SK2 6AA')
      end

      it 'correctly creates all the entities' do
        stub_teacher_training_api_courses(
          provider_code: 'ABC',
          specified_attributes: [{
            code: 'ABC1',
            accredited_body_code: 'ABC',
            study_mode: 'full_time',
            findable: true,
            summary: 'PGCE with QTS full time',
            start_date: '2021-09-01',
            course_length: 'OneYear',
            age_minimum: 4,
            age_maximum: 8,
          }],
        )
        stub_teacher_training_api_sites(
          provider_code: 'ABC',
          course_code: 'ABC1',
          specified_attributes: [{
            code: 'A',
            name: 'Main site',
            street_address_1: 'Gorse SCITT',
            street_address_2: 'Bruntcliffe Lane',
            city: 'Morley',
            county: 'Leeds',
            postcode: 'LS27 0LZ',
            latitude: 53.745587,
            longitude: -1.620208,
          }],
          vacancy_status: 'full_time_vacancies',
        )

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)

        course_option = CourseOption.last
        expect(course_option.course.uuid).to eq '906c6f3c-b2d6-46e1-8bf7-3fbd13d3ea06'
        expect(course_option.course.provider.code).to eq 'ABC'
        expect(course_option.course.provider.provider_type).to eq 'scitt'
        expect(course_option.course.provider.region_code).to eq 'south_west'
        expect(course_option.course.provider.postcode).to eq 'SK2 6AA'
        expect(course_option.course.code).to eq 'ABC1'
        expect(course_option.course.exposed_in_find).to be true
        expect(course_option.course.open_on_apply).to be false
        expect(course_option.course.recruitment_cycle_year).to eql stubbed_recruitment_cycle_year
        expect(course_option.course.description).to eq 'PGCE with QTS full time'
        expect(course_option.course.start_date).to eq Time.zone.local(2021, 9, 1)
        expect(course_option.course.course_length).to eq 'OneYear'
        expect(course_option.course.age_range).to eq '4 to 8'
        expect(course_option.site.name).to eq 'Main site'
        expect(course_option.site.address_line1).to eq 'Gorse SCITT'
        expect(course_option.site.address_line2).to eq 'Bruntcliffe Lane'
        expect(course_option.site.address_line3).to eq 'Morley'
        expect(course_option.site.address_line4).to eq 'Leeds'
        expect(course_option.site.postcode).to eq 'LS27 0LZ'
        expect(course_option.site.latitude).to eq 53.745587
        expect(course_option.site.longitude).to eq(-1.620208)
        expect(course_option.vacancy_status).to eq 'vacancies'
      end

      context 'mapping subjects to a course' do
        before do
          stub_teacher_training_api_courses(provider_code: 'ABC',
                                            specified_attributes: [{ code: 'ABC1', accredited_body_code: nil }])

          stub_teacher_training_api_sites(provider_code: 'ABC', course_code: 'ABC1',
                                          specified_attributes: [{}])
        end

        it 'when there is no entry for the subject it creates a new one' do
          expect {
            described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
          }.to change(Subject, :count).by(1)

          expect(Subject.exists?(code: '00')).to be true
        end

        it 'when the subject exists it associates the existing entry' do
          subject = create(:subject, code: '00')
          expect {
            described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
          }.to change(Subject, :count).by(0)

          course = Course.last
          expect(course.subjects).to contain_exactly(subject)
        end
      end

      it 'correctly handles missing address info' do
        stub_teacher_training_api_courses(
          provider_code: 'ABC',
          specified_attributes: [{
            code: 'ABC1',
            accredited_body_code: nil,
          }],
        )
        stub_teacher_training_api_sites(
          provider_code: 'ABC',
          course_code: 'ABC1',
          specified_attributes: [{
            code: 'A',
            name: 'Main site',
            street_address_1: 'Gorse SCITT',
            street_address_2: nil,
            city: 'Morley',
            county: 'Leeds',
            postcode: 'LS27 0LZ',

          }],
        )

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)

        course_option = CourseOption.last
        expect(course_option.site.address_line2).to be_nil
      end

      it 'correctly updates vacancy status for any existing course options' do
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ accredited_body_code: nil, study_mode: 'full_time' }],
                                                   site_code: 'A',
                                                   vacancy_status: 'full_time_vacancies')

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        expect(CourseOption.count).to eq 1
        CourseOption.first.update!(vacancy_status: 'no_vacancies')

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        expect(CourseOption.count).to eq 1
        expect(CourseOption.first.vacancy_status).to eq 'vacancies'
      end

      it 'correctly updates withdrawn attribute for an existing course' do
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ study_mode: 'full_time', accredited_body_code: nil, state: 'withdrawn' }],
                                                   site_code: 'A')

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        expect(CourseOption.count).to eq 1
        Course.first.update!(withdrawn: false)

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        expect(Course.first.withdrawn).to eq true
      end

      it 'sets the accredited provider' do
        create :provider, code: 'DEF', name: 'Foobar College'

        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ accredited_body_code: 'DEF' }],
                                                   site_code: 'A',
                                                   vacancy_status: 'full_time_vacancies')

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        course_option = CourseOption.first
        expect(course_option.course.accredited_provider.code).to eq 'DEF'
        expect(course_option.course.accredited_provider.name).to eq 'Foobar College'
      end

      it 'does not set the accredited provider if it is the same as the training provider' do
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ accredited_body_code: 'ABC' }],
                                                   site_code: 'A')

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        expect(Course.find_by(code: 'ABC1').accredited_provider).to be_nil
      end

      it 'resets the accredited provider if it is no longer specified' do
        course = create(:course, uuid: '9875793b-83b6-4a6f-a3d7-4775e76a9ae7', accredited_provider: create(:provider), code: 'ABC1', provider: create(:provider, code: 'ABC'))

        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ accredited_body_code: nil, uuid: '9875793b-83b6-4a6f-a3d7-4775e76a9ae7' }],
                                                   site_code: 'A')

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        expect(course.reload.accredited_provider).to be_nil
      end

      it 'correctly creates provider relationships' do
        create :provider, code: 'DEF'
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ accredited_body_code: 'DEF', study_mode: 'full_time' }],
                                                   site_code: 'A')

        expect {
          described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        }.to change(ProviderRelationshipPermissions, :count).by(1)

        permissions = ProviderRelationshipPermissions.last
        expect(permissions.ratifying_provider.code).to eq('DEF')
        expect(permissions.training_provider.code).to eq('ABC')
        expect(permissions.training_provider_can_view_safeguarding_information).to be false
        expect(permissions.ratifying_provider_can_view_safeguarding_information).to be false
      end

      it 'does not create provider relationships for self ratifying providers' do
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ accredited_body_code: nil, study_mode: 'full_time' }],
                                                   site_code: 'A')

        expect {
          described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        }.not_to change(ProviderRelationshipPermissions, :count)
      end

      it 'does not create provider relationships when the course accredited_provider attribute points back to the same provider' do
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ accredited_body_code: 'ABC', study_mode: 'full_time' }],
                                                   site_code: 'A')

        expect {
          described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        }.not_to change(ProviderRelationshipPermissions, :count)
      end

      it 'stores full_time/part_time information within courses' do
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ accredited_body_code: 'ABC', study_mode: 'both' }],
                                                   site_code: 'A')

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        expect(Course.find_by(code: 'ABC1').study_mode).to eq 'full_time_or_part_time'
      end

      it 'creates the correct number of course_options for sites and study_mode' do
        stub_teacher_training_api_courses(
          provider_code: 'ABC',
          specified_attributes: [{
            code: 'ABC1',
            accredited_body_code: 'ABC',
            study_mode: 'both',
          }],
        )
        stub_teacher_training_api_sites(
          provider_code: 'ABC',
          course_code: 'ABC1',
          specified_attributes: [{
            code: 'A',
          },
                                 {
                                   code: 'B',
                                 }],
        )

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)

        provider = Provider.find_by(code: 'ABC')
        course_options = Course.find_by(code: 'ABC1').course_options
        expect(course_options.count).to eq 4
        provider.sites.each do |site|
          modes_for_site = course_options.where(site_id: site.id).pluck(:study_mode)
          expect(modes_for_site).to match_array %w[full_time part_time]
        end
      end

      it 'correctly handles existing course options with invalid sites' do
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ accredited_body_code: nil, study_mode: 'full_time' }],
                                                   site_code: 'A',
                                                   vacancy_status: 'full_time_vacancies')

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
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
        create(:application_choice, course_option: valid_course_option, current_course_option: invalid_course_option_three)

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)
        expect(CourseOption.exists?(invalid_course_option_one.id)).to eq false
        expect(invalid_course_option_two.reload).not_to be_site_still_valid
        expect(invalid_course_option_three.reload).not_to be_site_still_valid
        expect(valid_course_option.reload).to be_site_still_valid
      end

      it 'automatically opens new courses on Sandbox', sandbox: true do
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ accredited_body_code: nil, study_mode: 'full_time' }],
                                                   site_code: 'A',
                                                   vacancy_status: 'full_time_vacancies')

        described_class.new.perform(existing_provider.id, stubbed_recruitment_cycle_year)

        course = Course.find_by(code: 'ABC1')

        expect(course.open_on_apply).to be true
        expect(course.opened_on_apply_at).not_to be_nil
      end
    end

    context 'ingesting a provider when it existed in the previous recruitment cycle' do
      let(:existing_provider) { create(:provider, code: 'ABC', sync_courses: true) }

      before do
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   recruitment_cycle_year: 2020,
                                                   course_attributes: [{ accredited_body_code: nil, study_mode: 'full_time' }],
                                                   site_code: 'A',
                                                   vacancy_status: 'full_time_vacancies')

        described_class.new.perform(existing_provider.id, 2020)
      end

      it 'creates separate courses for the courses in this cycle' do
        expect(Course.count).to eq 1

        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   recruitment_cycle_year: 2021,
                                                   course_attributes: [{ accredited_body_code: nil, study_mode: 'full_time' }],
                                                   site_code: 'A',
                                                   vacancy_status: 'full_time_vacancies')

        described_class.new.perform(existing_provider.id, 2021)
        expect(Course.count).to eq 2
      end

      it 'carries over the previous course’s open_on_apply status the first time it appears in the new cycle but not the second time' do
        existing_course = Course.find_by(recruitment_cycle_year: 2020)
        existing_course.update(open_on_apply: true)

        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   recruitment_cycle_year: 2021,
                                                   course_attributes: [{ accredited_body_code: nil, study_mode: 'full_time', uuid: SecureRandom.uuid }],
                                                   site_code: 'A',
                                                   vacancy_status: 'full_time_vacancies')

        described_class.new.perform(existing_provider.id, 2021)

        new_course = Course.find_by(recruitment_cycle_year: 2021)
        expect(new_course).to be_open_on_apply
        expect(new_course.opened_on_apply_at).not_to be_nil

        new_course.update(open_on_apply: false)

        described_class.new.perform(existing_provider.id, 2021)

        expect(new_course.reload).not_to be_open_on_apply
        expect(new_course.opened_on_apply_at).not_to be_nil
      end
    end

    describe 'Slack notification' do
      let(:accredited_body_code) { nil }

      let!(:provider) do
        create(:provider, code: 'ABC', name: 'University of Life', sync_courses: true)
      end

      before do
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   recruitment_cycle_year: RecruitmentCycle.current_year,
                                                   course_attributes: [{
                                                     accredited_body_code: accredited_body_code,
                                                     study_mode: 'full_time',
                                                   }],
                                                   site_code: 'A',
                                                   vacancy_status: 'full_time_vacancies')
      end

      it 'notifies Slack when the provider already has open courses on Apply in this cycle', sidekiq: true do
        create(:course, :open_on_apply, provider: provider) # existing course

        described_class.new.perform(provider.id, RecruitmentCycle.current_year)

        expect_slack_message_with_text('University of Life, which has courses open on Apply, added a new course. There’s no separate accredited body for this course.')
      end

      context 'the course from TTAPI has an accredited_body_code' do
        let(:accredited_body_code) { 'DEF' }

        it 'includes the accredited provider details when DSA is signed' do
          accredited_provider = create(:provider, :with_signed_agreement, code: 'DEF', name: 'Canterbury')
          create(:course, :open_on_apply, provider: provider, accredited_provider: accredited_provider) # existing course

          described_class.new.perform(provider.id, RecruitmentCycle.current_year)

          expect_slack_message_with_text('University of Life, which has courses open on Apply, added a new course. It’s ratified by Canterbury, who have signed the DSA.')
        end

        it 'includes the accredited provider details when DSA is not signed' do
          accredited_provider = create(:provider, code: 'DEF', name: 'Canterbury')
          create(:course, :open_on_apply, provider: provider, accredited_provider: accredited_provider) # existing course

          described_class.new.perform(provider.id, RecruitmentCycle.current_year)

          expect_slack_message_with_text('University of Life, which has courses open on Apply, added a new course. It’s ratified by Canterbury, who have NOT signed the DSA.')
        end
      end

      it 'does not notify Slack when the provider does not have open courses on Apply in this cycle', sidekiq: true do
        # existing course in wrong cycle
        create(:course, :open_on_apply, provider: provider, recruitment_cycle_year: RecruitmentCycle.previous_year)

        described_class.new.perform(provider.id, RecruitmentCycle.current_year)

        expect_no_slack_message
      end
    end
  end
end
