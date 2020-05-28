require 'rails_helper'

RSpec.describe SubmitReference do
  describe '#save!' do
    let(:application_form) { create(:completed_application_form) }

    context 'minimum required references received' do
      it 'progresses the application choices to the "application complete" status' do
        application_form = create(:completed_application_form, edit_by: 1.day.from_now)
        active_application_choice = create(:application_choice, application_form: application_form, status: 'awaiting_references')
        cancelled_application_choice = create(:application_choice, application_form: application_form, status: 'cancelled')

        create(:reference, :complete, application_form: application_form)
        reference = create(:reference, :unsubmitted, application_form: application_form)

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
        reference = create(:reference, :unsubmitted, application_form: application_form)

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
        reference = create(:reference, :unsubmitted, application_form: application_form)

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
        reference = create(:reference, :unsubmitted, application_form: application_form)

        reference.update!(feedback: 'Trustworthy', relationship_correction: '', safeguarding_concerns: '')

        SubmitReference.new(
          reference: reference,
        ).save!

        another_reference = create(:reference, :unsubmitted, application_form: application_form)

        another_reference.update!(feedback: 'Trustworthy', relationship_correction: '', safeguarding_concerns: '')

        SubmitReference.new(
          reference: another_reference,
        ).save!
      end
    end
  end
end
