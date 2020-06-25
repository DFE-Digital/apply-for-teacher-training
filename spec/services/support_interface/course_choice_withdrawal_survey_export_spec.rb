require 'rails_helper'

RSpec.describe SupportInterface::CourseChoiceWithdrawalSurveyExport do
  describe '#call' do
    it 'returns a hash of candidates course choice withdrawal survey answers' do
      application_choice1 = create(:application_choice, :withdrawn_with_survey_completed)
      application_choice2 = create(:application_choice, :withdrawn_with_survey_completed)
      application_choice3 = create(:application_choice, :withdrawn_with_survey_completed)
      create(:application_choice)

      expect(described_class.call).to match_array([return_expected_hash(application_choice1), return_expected_hash(application_choice2), return_expected_hash(application_choice3)])
    end
  end

private

  def return_expected_hash(application_choice)
    survey = application_choice.withdrawal_feedback
    {
      'Name' => application_choice.application_form.full_name,
      CandidateInterface::WithdrawalQuestionnaire::EXPLANATION_QUESTION => 'yes',
      'Explanation' => survey['Explanation'],
      CandidateInterface::WithdrawalQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => 'yes',
      'Contact details' => survey['Contact details'],
    }
  end
end
