require 'rails_helper'

RSpec.describe SupportInterface::RefereeSurveyExport do
  describe 'documentation' do
    let(:questionnaire) do
      {
        RefereeQuestionnaire::GUIDANCE_QUESTION => 'very_poor | I could not read it.',
        RefereeQuestionnaire::EXPERIENCE_QUESTION => 'very_good | I could read it.',
        RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => 'yes | 02113131',

        # Legacy question that is no longer asked.
        'If we asked whether a candidate was safe to work with children, would you feel able to answer?' => 'yes | ',
      }
    end

    before do
      create(:reference, questionnaire: questionnaire, application_form: create(:application_form, recruitment_cycle_year: 2021))
    end

    it_behaves_like 'a data export'
  end

  describe '#call' do
    let(:questionnaire1) do
      {
        RefereeQuestionnaire::GUIDANCE_QUESTION => 'very_poor | I could not read it.',
        RefereeQuestionnaire::EXPERIENCE_QUESTION => 'very_good | I could read it.',
        RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => 'yes | 02113131',

        # Legacy question that is no longer asked.
        'If we asked whether a candidate was safe to work with children, would you feel able to answer?' => 'yes | ',
      }
    end

    let(:questionnaire2) do
      {
        RefereeQuestionnaire::GUIDANCE_QUESTION => 'good | ',
        RefereeQuestionnaire::EXPERIENCE_QUESTION => 'poor | ',
        RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => ' | ',
      }
    end

    let(:questionnaire3) do
      {
        RefereeQuestionnaire::GUIDANCE_QUESTION => ' | ',
        RefereeQuestionnaire::EXPERIENCE_QUESTION => ' | ',
        RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => ' | ',
      }
    end

    it 'returns a hash of non-duplicate referees responses' do
      create(:reference, name: 'A', email_address: 'a@example.com', questionnaire: questionnaire1, feedback_provided_at: '2021-01-01 15:00:00', application_form: create(:application_form, recruitment_cycle_year: 2021))
      create(:reference, name: 'B', email_address: 'b@example.com', questionnaire: questionnaire2, feedback_provided_at: '2021-02-01 15:00:00', application_form: create(:application_form, recruitment_cycle_year: 2021))
      create(:reference, questionnaire: questionnaire3, application_form: create(:application_form, recruitment_cycle_year: 2021))
      create(:reference, name: 'A', email_address: 'a@example.com', questionnaire: questionnaire1, duplicate: true, application_form: create(:application_form, recruitment_cycle_year: 2021))

      expect(described_class.new.call).to match_array([
        {
          reference_name: 'A',
          reference_provided_at: '01/01/21',
          recruitment_cycle_year: 2021,
          reference_email_address: 'a@example.com',
          guidance_rating: 'very_poor',
          guidance_explanation: 'I could not read it.',
          experience_rating: 'very_good',
          experience_explanation: 'I could read it.',
          consent_to_be_contacted: 'yes',
          contact_details: '02113131',
        },
        {
          reference_name: 'B',
          reference_provided_at: '01/02/21',
          recruitment_cycle_year: 2021,
          reference_email_address: 'b@example.com',
          guidance_rating: 'good',
          guidance_explanation: nil,
          experience_rating: 'poor',
          experience_explanation: nil,
          consent_to_be_contacted: nil,
          contact_details: nil,
        },
      ])
    end
  end
end
