require 'rails_helper'

RSpec.describe CandidateInterface::SubmitApplicationChoice do
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
        travel_temporarily_to(Time.zone.local(0)) do
          submit_application
          expect(application_form.submitted_at).to eq Time.zone.local(0)
          expect(application_choice.sent_to_provider_at).to eq Time.zone.local(0)
        end
      end

      it 'does not updated submitted_at for a second application choice' do
        submit_application

        travel_temporarily_to(Time.zone.local(0)) do
          new_application_choice = create(:application_choice, :unsubmitted, application_form: application_form)
          expect {
            described_class.new(new_application_choice).call
          }.not_to(change { application_form.reload.submitted_at })
        end
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

      it 'duplicates the work experiences on the application_choice even if work_experiences exist' do
        work_experience = create(
          :application_work_experience,
          experienceable: application_form,
        )

        choice_work_experience = create(
          :application_work_experience,
          experienceable: application_choice,
        )

        unexpected_ids = application_form.application_work_experiences.ids << choice_work_experience.id

        expect {
          submit_application
        }.not_to change(application_choice.work_experiences, :count)

        expect(application_choice.work_experiences.pluck(:details)).to eq(
          [work_experience.details],
        )
        expect(application_choice.work_experiences.ids).not_to eq(
          unexpected_ids,
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

      it 'duplicates the volunteering experiences on the application_choice even if volunteering_experiences exist' do
        volunteering_experience = create(
          :application_volunteering_experience,
          experienceable: application_form,
        )

        choice_volunteering_experience = create(
          :application_volunteering_experience,
          experienceable: application_choice,
        )

        unexpected_ids = application_form.application_volunteering_experiences.ids << choice_volunteering_experience.id

        expect {
          submit_application
        }.not_to change(application_choice.volunteering_experiences, :count)

        expect(application_choice.volunteering_experiences.pluck(:details)).to eq(
          [volunteering_experience.details],
        )
        expect(application_choice.volunteering_experiences.ids).not_to eq(
          unexpected_ids,
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

      it 'duplicates the work history breaks on the application_choice even if work history breaks exist' do
        work_history_break = create(
          :application_work_history_break,
          breakable: application_form,
        )

        choice_work_history_break = create(
          :application_work_history_break,
          breakable: application_choice,
        )

        unexpected_ids = application_form.application_work_history_breaks.ids << choice_work_history_break.id

        expect {
          submit_application
        }.not_to change(application_choice.work_history_breaks, :count)

        expect(application_choice.work_history_breaks.pluck(:reason)).to eq(
          [work_history_break.reason],
        )
        expect(application_choice.work_history_breaks.ids).not_to eq(
          unexpected_ids,
        )
      end
    end
  end
end
