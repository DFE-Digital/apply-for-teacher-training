require 'rails_helper'

RSpec.describe SupportInterface::RefereeSurveyExport do
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

    it 'returns a hash of referees responses' do
      create(:reference, name: 'A', email_address: 'a@example.com', questionnaire: questionnaire1, feedback_provided_at: '2021-01-01 15:00:00', application_form: create(:application_form, recruitment_cycle_year: 2021))
      create(:reference, name: 'B', email_address: 'b@example.com', questionnaire: questionnaire2, application_form: create(:application_form, recruitment_cycle_year: 2021))
      create(:reference, questionnaire: questionnaire3, application_form: create(:application_form, recruitment_cycle_year: 2021))

      expect(described_class.new.call).to match_array([
        {
          'Name' => 'A',
          'Reference provided at' => '2021-01-01T15:00:00+00:00',
          'Recruitment cycle year' => 2021,
          'Email_address' => 'a@example.com',
          'Guidance rating' => 'very_poor',
          'Guidance explanation' => 'I could not read it.',
          'Experience rating' => 'very_good',
          'Experience explanation' => 'I could read it.',
          'Consent to be contacted' => 'yes',
          'Contact details' => '02113131',
        },
        {
          'Name' => 'B',
          'Reference provided at' => nil,
          'Recruitment cycle year' => 2021,
          'Email_address' => 'b@example.com',
          'Guidance rating' => 'good',
          'Guidance explanation' => nil,
          'Experience rating' => 'poor',
          'Experience explanation' => nil,
          'Consent to be contacted' => nil,
          'Contact details' => nil,
        },
      ])
    end
  end
end
