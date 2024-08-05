require 'rails_helper'

RSpec.describe EndOfCycle::RejectByDefaultService do
  describe '#call' do
    it 'only rejects application choices in rejectable states' do
      application_form = create(:application_form)
      inactive_choice = create(:application_choice, :inactive, application_form:)
      interviewing_choice = create(:application_choice, :interviewing, application_form:)
      awaiting_decision_choice = create(:application_choice, :awaiting_provider_decision, application_form:)
      offered_choice = create(:application_choice, :offer, application_form:)

      described_class.new(application_form).call

      expect(inactive_choice.reload.status).to eq('rejected')
      expect(inactive_choice.rejected_by_default).to be(true)
      expect(interviewing_choice.reload.status).to eq('rejected')
      expect(interviewing_choice.rejected_by_default).to be(true)
      expect(awaiting_decision_choice.reload.status).to eq('rejected')
      expect(awaiting_decision_choice.rejected_by_default).to be(true)

      expect(offered_choice.reload.status).to eq('offer')
      expect(offered_choice.rejected_by_default).to be(false)
    end

    it 'cancels interviews' do
      application_form = create(:application_form)
      interviewing_choice = create(:application_choice, :interviewing, application_form:)
      interview = interviewing_choice.interviews.kept.upcoming_not_today.first

      described_class.new(application_form).call

      expect(interview.reload.cancellation_reason).to eq('Your application was unsuccessful.')
    end
  end
end
