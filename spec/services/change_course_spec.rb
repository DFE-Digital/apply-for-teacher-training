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

  let(:change_course) do
    described_class.new(
      actor: provider_user,
      application_choice: application_choice,
      course_option: course_option,
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

      it 'then it calls various services' do
        allow(application_choice).to receive(:update_course_option_and_associated_fields!)

        change_course.save!

        expect(application_choice).to have_received(:update_course_option_and_associated_fields!)
      end
    end

    describe 'audits', with_audited: true do
      it 'generates an audit event combining status change with current_course_option_id' do
        change_course.save!

        audit_with_status_change = application_choice.reload.audits.find_by('jsonb_exists(audited_changes, ?)', 'status')
        expect(audit_with_status_change.audited_changes).to have_key('current_course_option_id')
      end
    end
  end
end
