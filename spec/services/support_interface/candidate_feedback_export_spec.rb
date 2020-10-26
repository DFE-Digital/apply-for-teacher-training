require 'rails_helper'

RSpec.describe SupportInterface::CandidateFeedbackExport do
  describe '#data_for_export' do
    it 'returns a hash of candidates satisfaction survey answers' do
      application_form1 = create(:completed_application_form, :with_feedback_completed)
      application_form2 = create(:completed_application_form, :with_feedback_completed)
      application_form3 = create(:completed_application_form, :with_feedback_completed)
      create(:completed_application_form)

      expect(described_class.new.data_for_export).to match_array([
        expected_hash(application_form1),
        expected_hash(application_form2),
        expected_hash(application_form3),
      ])
    end
  end

private

  def expected_hash(application_form)
    {
      'Name' => application_form.full_name,
      'Recruitment cycle year' => application_form.recruitment_cycle_year,
      'Email_address' => application_form.candidate.email_address,
      'Phone number' => application_form.phone_number,
      'Submitted at' => application_form.submitted_at,
      'Satisfaction level' => application_form.feedback_satisfaction_level,
      'CSAT score' => described_class::CSAT_SCORES[application_form.feedback_satisfaction_level],
      'Suggestions' => application_form.feedback_suggestions,
    }
  end
end
