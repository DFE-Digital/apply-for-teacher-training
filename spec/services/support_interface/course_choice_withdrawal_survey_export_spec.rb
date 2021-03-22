require 'rails_helper'

RSpec.describe SupportInterface::CourseChoiceWithdrawalSurveyExport do
  describe '#call' do
    it 'returns a hash of candidates course choice withdrawal survey answers' do
      application_choice1 = create(:application_choice, :withdrawn_with_survey_completed)
      application_choice2 = create(:application_choice, :withdrawn_with_survey_completed)
      application_choice3 = create(:application_choice, :withdrawn_with_survey_completed)
      create(:application_choice)

      expect(described_class.new.data_for_export).to match_array([return_expected_hash(application_choice1), return_expected_hash(application_choice2), return_expected_hash(application_choice3)])
    end
  end

private

  def return_expected_hash(application_choice)
    survey = application_choice.withdrawal_feedback
    {
      full_name: application_choice.application_form.full_name,
      explanation: survey['Explanation'],
      contact_details: survey['Contact details'],
      reason_for_withdrawing: 'yes',
      consent_to_be_contacted: 'yes',

    }
  end
end
