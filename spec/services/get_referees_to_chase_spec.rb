require 'rails_helper'

RSpec.describe GetRefereesToChase do
  describe '#perform' do
    it 'returns all referees that were sent their reference email more than 5 days ago' do
      application_form1 = create(:application_form, submitted_at: 6.days.ago)
      application_form2 = create(:application_form, submitted_at: 4.days.ago)
      application_form3 = create(:application_form, submitted_at: 6.days.ago)

      reference1 = create(:reference, feedback_status: 'feedback_requested', application_form: application_form1)
      create(:reference, :complete, application_form: application_form1)
      create(:reference, feedback_status: 'feedback_requested', application_form: application_form2)
      create(:reference, :complete, application_form: application_form2)
      create(:reference, feedback_status: 'feedback_requested', application_form: application_form3)
      create(:reference, :complete, application_form: application_form3)

      create(:application_choice, application_form: application_form1, status: 'awaiting_references')
      create(:application_choice, application_form: application_form2, status: 'awaiting_references')
      create(:application_choice, application_form: application_form2, status: 'application_complete')

      service = described_class.new.perform

      expect(service).to eq [reference1]
    end
  end
end
