require 'rails_helper'

RSpec.describe SubmitReference do
  describe '#save!' do
    describe 'decoupled_references feature ON' do
      before { FeatureFlag.activate(:decoupled_references) }

      it 'updates the reference state to "feedback_provided"' do
        application_choice = create(:application_choice, status: :unsubmitted)
        application_form = application_choice.application_form
        reference_one = create(:reference, :feedback_requested)
        reference_two = create(:reference, :feedback_requested, application_form: reference_one.application_form)

        SubmitReference.new(reference: reference_one).save!
        SubmitReference.new(reference: reference_two).save!

        expect(reference_one).to be_feedback_provided
        expect(reference_two).to be_feedback_provided
        expect(application_form.reload.application_choices).to all(be_unsubmitted)
      end

      context 'when the second reference is received' do
        it 'cancels reference requests for all remaining "awaiting_feedback" references' do
          application_form = create(:application_form)
          reference1 = create(:reference, :feedback_requested, application_form: application_form)
          reference2 = create(:reference, :feedback_requested, application_form: application_form)
          reference3 = create(:reference, :feedback_refused, application_form: application_form)
          reference4 = create(:reference, :feedback_requested, application_form: application_form)

          SubmitReference.new(reference: reference1).save!
          SubmitReference.new(reference: reference2).save!

          expect(reference1).to be_feedback_provided
          expect(reference2).to be_feedback_provided
          expect(reference3.reload).to be_feedback_refused
          expect(reference4.reload).to be_cancelled
        end
      end
    end

    describe 'decoupled_references feature OFF' do
      before { FeatureFlag.deactivate(:decoupled_references) }

      let(:application_form) { create(:completed_application_form) }

      context 'minimum required references received' do
        it 'progresses the application choices to the "application complete" status' do
          application_form = create(:completed_application_form, edit_by: 1.day.from_now)
          active_application_choice = create(:application_choice, application_form: application_form, status: 'awaiting_references')
          cancelled_application_choice = create(:application_choice, application_form: application_form, status: 'cancelled')

          create(:reference, :complete, application_form: application_form)
          reference = create(:reference, :not_requested_yet, application_form: application_form)

          reference.update!(feedback: 'Trustworthy', relationship_correction: '', safeguarding_concerns: '')

          SubmitReference.new(
            reference: reference,
          ).save!

          expect(active_application_choice.reload).to be_application_complete
          expect(cancelled_application_choice.reload).to be_cancelled
        end

        it 'progresses the application choices to the "awaiting_provider_decision" if edit_by has elapsed' do
          application_form = create(:completed_application_form, edit_by: 1.day.ago)
          create(:application_choice, application_form: application_form, status: 'awaiting_references')
          create(:reference, :complete, application_form: application_form)
          reference = create(:reference, :not_requested_yet, application_form: application_form)

          reference.update!(feedback: 'Trustworthy', relationship_correction: '', safeguarding_concerns: '')

          SubmitReference.new(
            reference: reference,
          ).save!

          expect(application_form.reload.application_choices).to all(be_awaiting_provider_decision)
        end

        it 'sets edit_by to current time if the candidate is applying again' do
          application_form = create(:completed_application_form, previous_application_form: create(:application_form), edit_by: 2.days.from_now)
          create(:application_choice, application_form: application_form, status: 'awaiting_references')
          create(:reference, :complete, application_form: application_form)
          reference = create(:reference, :not_requested_yet, application_form: application_form)

          reference.update!(feedback: 'Trustworthy', relationship_correction: '', safeguarding_concerns: '')

          Timecop.freeze(Time.utc(2020)) do
            SubmitReference.new(
              reference: reference,
            ).save!

            expect(application_form.edit_by).to eq Time.utc(2020)
          end
        end

        it 'is okay with a 3rd reference being provided' do
          application_form = create(:completed_application_form, edit_by: 1.day.ago)

          create(:application_choice, application_form: application_form, status: 'awaiting_references')
          create(:reference, :complete, application_form: application_form)
          reference = create(:reference, :not_requested_yet, application_form: application_form)

          reference.update!(feedback: 'Trustworthy', relationship_correction: '', safeguarding_concerns: '')

          SubmitReference.new(
            reference: reference,
          ).save!

          another_reference = create(:reference, :not_requested_yet, application_form: application_form)

          another_reference.update!(feedback: 'Trustworthy', relationship_correction: '', safeguarding_concerns: '')

          SubmitReference.new(
            reference: another_reference,
          ).save!
        end
      end
    end
  end
end
