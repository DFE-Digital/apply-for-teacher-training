require 'rails_helper'

module CandidateInterface
  RSpec.describe SubmitApplicationChoice do
    subject(:submit_application) { described_class.new(application_choice).call }

    let(:application_form) { application_choice.application_form }

    describe '#call' do
      context 'when application is already submitted' do
        let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }

        it 'raises error' do
          expect {
            submit_application
          }.to raise_error(
            CandidateInterface::ApplicationNotReadyToSendError,
            'Tried to send an application in the awaiting_provider_decision state to a provider',
          )
        end
      end

      context 'when application is unsubmitted' do
        let(:application_choice) { create(:application_choice, :unsubmitted) }

        it 'updates timestamps relevant to submitting an application' do
          submitted_at_time = 5.minutes.ago
          travel_temporarily_to(submitted_at_time) do
            submit_application
            expect(application_form.submitted_at).to be_within(1.second).of(submitted_at_time)
            expect(application_choice.sent_to_provider_at).to be_within(1.second).of(submitted_at_time)
          end
        end

        it 'does not updated submitted_at for a second application choice' do
          submit_application

          new_application_choice = create(:application_choice, :unsubmitted, application_form: application_form)
          expect {
            described_class.new(new_application_choice).call
          }.not_to(change { application_form.reload.submitted_at })
        end

        it 'updates inactive date for application' do
          travel_temporarily_to(Time.zone.local(2023, 10, 20)) do
            submit_application
            expect(application_choice.reject_by_default_at).to be_within(1.second).of(Time.zone.parse('01 Dec 2023 23:59:59 GMT'))
            expect(application_choice.reject_by_default_days).to eq 30
          end
        end

        it 'updates application choice status' do
          expect(application_choice).to be_unsubmitted
          submit_application
          expect(application_choice).to be_awaiting_provider_decision
        end

        it 'sets the personal_statement to the value of the application form becoming_a_teacher' do
          submit_application
          expect(application_choice.personal_statement).to eq application_form.becoming_a_teacher
        end

        it 'sends the candidate an email notifying them of their submission' do
          expect {
            submit_application
          }.to have_enqueued_mail(CandidateMailer, :application_choice_submitted)
        end

        it 'sends the provider an email notifying them of the submission' do
          provider = application_choice.course.provider
          provider.provider_users << create(:provider_user, :with_notifications_enabled)

          expect {
            submit_application
          }.to have_enqueued_mail(ProviderMailer, :application_submitted)
        end

        it 'duplicates the work experiences on the application_choice' do
          work_experience = create(
            :application_work_experience,
            experienceable: application_form,
          )

          expect {
            submit_application
          }.to change(application_choice.work_experiences, :count).by(1)

          expect(application_choice.work_experiences.pluck(:details)).to eq(
            [work_experience.details],
          )
          expect(application_choice.work_experiences.ids).not_to eq(
            application_form.application_work_experiences.ids,
          )
        end

        it 'duplicates the volunteering experiences on the application_choice' do
          volunteering_experience = create(
            :application_volunteering_experience,
            experienceable: application_form,
          )

          expect {
            submit_application
          }.to change(application_choice.volunteering_experiences, :count).by(1)

          expect(application_choice.volunteering_experiences.pluck(:details)).to eq(
            [volunteering_experience.details],
          )
          expect(application_choice.volunteering_experiences.ids).not_to eq(
            application_form.application_volunteering_experiences.ids,
          )
        end

        it 'duplicates the work history breaks on the application_choice' do
          work_history_break = create(
            :application_work_history_break,
            breakable: application_form,
          )

          expect {
            submit_application
          }.to change(application_choice.work_history_breaks, :count).by(1)

          expect(application_choice.work_history_breaks.pluck(:reason)).to eq(
            [work_history_break.reason],
          )
          expect(application_choice.work_history_breaks.ids).not_to eq(
            application_form.application_work_history_breaks.ids,
          )
        end

        it 'calls LocationPreferences.add_dynamic_location' do
          allow(LocationPreferences).to receive(:add_dynamic_location).with(
            preference: nil,
            application_choice:,
          ).and_return(nil)

          submit_application

          expect(LocationPreferences).to have_received(:add_dynamic_location).with(
            preference: nil,
            application_choice:,
          )
        end
      end
    end
  end
end
