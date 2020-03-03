require 'rails_helper'

RSpec.describe SubmitApplicationChoice do
  describe 'Submit an application choice', sandbox: false do
    let(:application_form) { create(:application_form, submitted_at: Time.zone.now) }
    let(:application_choice) { create(:application_choice, application_form: application_form, status: 'unsubmitted') }

    it 'updates the application choice to Submitted' do
      SubmitApplicationChoice.new(application_choice).call
      expect(application_choice).to be_awaiting_references
    end

    it 'updates the application choice to edit_by date' do
      days_to_edit = TimeLimitCalculator.new(rule: :edit_by, effective_date: application_form.submitted_at).call[:days]
      expected_edit_by_day = days_to_edit.business_days.after(application_form.submitted_at).end_of_day

      SubmitApplicationChoice.new(application_choice).call
      expect(application_choice.edit_by).to eq(expected_edit_by_day)
    end

    context 'when running in a provider sandbox', sandbox: true do
      it 'sets the edit_by timestamp to now' do
        now = Time.zone.local(2019, 11, 11, 15, 0, 0)
        Timecop.freeze(now) do
          SubmitApplicationChoice.new(application_choice).call

          expect(application_choice.edit_by).to eq now
        end
      end
    end
  end
end
