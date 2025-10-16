require 'rails_helper'

RSpec.describe ChangeCourse do
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, status: :awaiting_provider_decision) }
  let(:provider_user) do
    create(
      :provider_user,
      :with_make_decisions,
      providers: [application_choice.current_course_option.provider],
    )
  end
  let(:course_option) { course_option_for_provider(provider: application_choice.current_course_option.provider, course: application_choice.current_course_option.course) }
  let(:update_interviews_provider_service) { instance_double(UpdateInterviewsProvider, save!: nil, notify: nil) }
  let(:change_course) do
    described_class.new(
      actor: provider_user,
      application_choice:,
      course_option:,
      update_interviews_provider_service:,
    )
  end

  before do
    mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
    allow(CandidateMailer).to receive(:change_course).and_return(mailer)
  end

  describe '#save!' do
    describe 'if the actor is not authorised to perform this action' do
      let(:provider_user) do
        create(:provider_user,
               providers: [application_choice.current_course_option.provider])
      end

      it 'throws an exception' do
        expect {
          change_course.save!
        }.to raise_error(
          ProviderAuthorisation::NotAuthorisedError,
          'You do not have the required user level permissions to make decisions on applications for this provider.',
        )
      end
    end

    describe 'if the provided details are correct' do
      let(:application_choice) { create(:application_choice, status: :awaiting_provider_decision) }
      let(:provider_user) do
        create(:provider_user,
               :with_make_decisions,
               providers: [application_choice.course_option.provider])
      end

      it 'then it calls the services' do
        allow(application_choice).to receive(:update_course_option_and_associated_fields!)

        change_course.save!

        expect(application_choice).to have_received(:update_course_option_and_associated_fields!)
        expect(update_interviews_provider_service).to have_received(:save!)
        expect(update_interviews_provider_service).to have_received(:notify)
      end

      it 'sets the course_changed_at attribute' do
        time = Time.zone.now
        travel_temporarily_to(time) do
          change_course.save!

          expect(application_choice.reload.course_changed_at).to be_within(1.second).of(time)
        end
      end
    end

    describe 'if the change is invalid' do
      let(:application_choice) { create(:application_choice, status: :awaiting_provider_decision, current_course_option: course_option, course_option:) }
      let(:course_option) { create(:course_option) }

      let(:provider_user) do
        create(:provider_user,
               :with_make_decisions,
               providers: [application_choice.course_option.provider])
      end

      it 'does not call the service' do
        expect {
          change_course.save!
        }.to raise_error(IdenticalCourseError)
        .and not_change(application_choice, :updated_at)
      end
    end

    describe 'audits', :with_audited do
      it 'generates an audit event combining status change with current_course_option_id' do
        change_course.save!

        audit_with_status_change = application_choice.reload.audits.find_by('jsonb_exists(audited_changes, ?)', 'status')
        expect(audit_with_status_change.audited_changes).to have_key('current_course_option_id')
      end
    end

    describe 'emails' do
      it 'sends an email when the course changes' do
        old_course_option = application_choice.course_option
        new_course = create(:course, provider: old_course_option.course.provider)
        new_course_option = create(:course_option, course: new_course)

        change_course = described_class.new(
          actor: provider_user,
          application_choice:,
          course_option: new_course_option,
          update_interviews_provider_service:,
        )

        change_course.save!

        expect(CandidateMailer).to have_received(:change_course).with(application_choice, old_course_option)
      end

      it 'does not send an email when only the site changes and placement is not auto-selected' do
        old_course_option = application_choice.course_option

        new_site = create(:site, provider: old_course_option.provider)
        same_course_option_with_new_site = create(
          :course_option,
          course: old_course_option.course,
          site: new_site,
          study_mode: old_course_option.study_mode,
        )

        application_choice.update!(school_placement_auto_selected: false)

        change_course = described_class.new(
          actor: provider_user,
          application_choice: application_choice,
          course_option: same_course_option_with_new_site,
          update_interviews_provider_service: update_interviews_provider_service,
        )

        change_course.save!

        expect(CandidateMailer).not_to have_received(:change_course)
      end

      it 'raises IdenticalCourseError and does not send an email when the course has not changed at all' do
        unchanged_course_option = application_choice.course_option

        change_course = described_class.new(
          actor: provider_user,
          application_choice:,
          course_option: unchanged_course_option,
          update_interviews_provider_service:,
        )

        expect {
          change_course.save!
        }.to raise_error(IdenticalCourseError)

        expect(CandidateMailer).not_to have_received(:change_course)
      end
    end
  end
end
