require 'rails_helper'

RSpec.describe DataMigrations::BackfillSelectedBoolean do
  it 'sets selected to true for feedback provided references' do
    reference = create(:reference, feedback_status: 'feedback_provided', selected: false)
    described_class.new.change
    expect(reference.reload.selected).to eq true
  end

  it 'does not set selected to true for all other feedback statuses' do
    states_minus_feedback_provided = ApplicationReference.feedback_statuses.values.reject do |status|
      status == 'feedback_provided'
    end

    states_minus_feedback_provided.each do |status|
      reference = create(:reference, feedback_status: status, selected: false)
      described_class.new.change
      expect(reference.reload.selected).to eq false
    end
  end
end
