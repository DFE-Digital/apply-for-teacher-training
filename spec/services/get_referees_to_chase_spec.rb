require 'rails_helper'

RSpec.describe GetRefereesToChase do
  describe '#perform' do
    it 'returns referees that were sent their reference email more than 5 days ago and have not already been chased' do
      application_form = create(:application_form, submitted_at: 6.days.ago)
      reference = create(:reference, feedback_status: 'feedback_requested', application_form: application_form)
      create(:application_choice, application_form: application_form, status: 'awaiting_references')

      service = described_class.new.perform

      expect(service).to eq [reference]
    end

    it 'only return sapplciation choices which are awaiting references' do
      application_form = create(:application_form, submitted_at: 6.days.ago)
      create(:reference, :complete, application_form: application_form)
      create(:application_choice, application_form: application_form, status: 'application_complete')

      service = described_class.new.perform

      expect(service).to be_empty
    end

    it 'does not return referees which were sent their reference email less than 5 days ago' do
      application_form = create(:application_form, submitted_at: 4.days.ago)
      create(:reference, feedback_status: 'feedback_requested', application_form: application_form)
      create(:application_choice, application_form: application_form, status: 'awaiting_references')


      service = described_class.new.perform

      expect(service).to be_empty
    end


    it 'does not return referess who have already been sent a chase email' do
      application_form = create(:application_form, submitted_at: 6.days.ago)
      reference = create(:reference, feedback_status: 'feedback_requested', application_form: application_form)
      create(:application_choice, application_form: application_form, status: 'awaiting_references')


      SendChaseEmail.new.perform(reference: reference)
      service = described_class.new.perform

      expect(service).to be_empty
    end
  end
end
