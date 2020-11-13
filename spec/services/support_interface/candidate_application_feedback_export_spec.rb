require 'rails_helper'

RSpec.describe SupportInterface::CandidateApplicationFeedbackExport do
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
      'Name' => application_feedback.application_form.full_name,
      'Recruitment cycle year' => application_feedback.application_form.recruitment_cycle_year,
      'Email_address' => application_feedback.application_form.candidate.email_address,
      'Phone number' => application_feedback.application_form.phone_number,
      'Submitted at' => application_feedback.created_at.iso8601,
      'Path' => application_feedback.path,
      'Page title' => application_feedback.page_title,
      'Understood the section' => !application_feedback.does_not_understand_section,
      'Needed more information' => application_feedback.need_more_information,
      'Answer does not fit the format' => application_feedback.answer_does_not_fit_format,
      'Other feedback' => application_feedback.other_feedback,
      'Consent to be contacted' => application_feedback.consent_to_be_contacted,
    }
  end
end
