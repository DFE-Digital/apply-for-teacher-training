require 'rails_helper'

RSpec.describe SupportInterface::CandidateFeedbackExport do
  describe 'documentation' do
    before do
      create(:completed_application_form, :with_feedback_completed)
    end

    it_behaves_like 'a data export'
  end

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
      full_name: application_form.full_name,
      recruitment_cycle_year: application_form.recruitment_cycle_year,
      email: application_form.candidate.email_address,
      phone_number: application_form.phone_number,
      submitted_at: application_form.submitted_at,
      satisfaction_level: application_form.feedback_satisfaction_level,
      csat_score: described_class::CSAT_SCORES[application_form.feedback_satisfaction_level],
      suggestions: application_form.feedback_suggestions,
    }
  end
end
