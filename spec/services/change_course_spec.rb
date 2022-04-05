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
  let(:update_interviews_provider_service) { instance_double(UpdateInterviewsProvider, save!: true) }

  let(:change_course) do
    described_class.new(
      actor: provider_user,
      application_choice: application_choice,
      course_option: course_option,
      update_interviews_provider_service: update_interviews_provider_service,
    )
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
      end
    end

    describe 'if the change is invalid' do
      let(:application_choice) { create(:application_choice, status: :awaiting_provider_decision, current_course_option: course_option, course_option: course_option) }
      let(:course_option) { create(:course_option, :open_on_apply) }

      let(:provider_user) do
        create(:provider_user,
               :with_make_decisions,
               providers: [application_choice.course_option.provider])
      end

      it 'does not call the service' do
        expect {
          change_course.save!
        }.to raise_error(IdenticalCourseError)
        .and change { application_choice.updated_at }.by(0)
      end
    end

    describe 'audits', with_audited: true do
      it 'generates an audit event combining status change with current_course_option_id' do
        change_course.save!

        audit_with_status_change = application_choice.reload.audits.find_by('jsonb_exists(audited_changes, ?)', 'status')
        expect(audit_with_status_change.audited_changes).to have_key('current_course_option_id')
      end
    end

    describe 'emails', sidekiq: true do
      it 'sends an email' do
        change_course.save!

        expect(ActionMailer::Base.deliveries.first['rails-mail-template'].value).to eq('change_course')
      end
    end
  end
end
