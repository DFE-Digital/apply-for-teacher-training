require 'rails_helper'

RSpec.describe SupportInterface::CandidateApplicationFeedbackExport do
  describe 'documentation' do
    before do
      application_form = create(:application_form)
      create(:application_feedback, application_form: application_form)
    end

    it_behaves_like 'a data export'
  end

  describe '#data_for_export' do
    it 'returns a hash of candidates satisfaction survey answers' do
      application_form1 = create(:application_form, first_name: 'Theo')
      application_form2 = create(:application_form, first_name: 'Vararu')
      application_feedback1 = create(:application_feedback, application_form: application_form1)
      application_feedback2 = create(:application_feedback, application_form: application_form2)
      application_feedback3 = create(:application_feedback, application_form: application_form1)

      expect(described_class.new.data_for_export).to eql([
        expected_hash(application_feedback1),
        expected_hash(application_feedback3),
        expected_hash(application_feedback2),
      ])
    end
  end

private

  def expected_hash(application_feedback)
    {
      full_name: application_feedback.application_form.full_name,
      recruitment_cycle_year: application_feedback.application_form.recruitment_cycle_year,
      email: application_feedback.application_form.candidate.email_address,
      phone_number: application_feedback.application_form.phone_number,
      submitted_at: application_feedback.created_at.iso8601,
      path: application_feedback.path,
      page_title: application_feedback.page_title,
      feedback: application_feedback.feedback,
      consent_to_be_contacted: application_feedback.consent_to_be_contacted,
    }
  end
end
