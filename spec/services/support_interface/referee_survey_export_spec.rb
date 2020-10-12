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
      reference1 = create(:reference, questionnaire: questionnaire1, application_form: create(:application_form, recruitment_cycle_year: 2021))
      reference2 = create(:reference, questionnaire: questionnaire2, application_form: create(:application_form, recruitment_cycle_year: 2021))
      create(:reference, questionnaire: questionnaire3, application_form: create(:application_form, recruitment_cycle_year: 2021))

      expect(described_class.new.call).to match_array([return_expected_hash(reference1), return_expected_hash(reference2)])
    end
  end

private

  def extract_rating(reference, field)
    get_response(reference.questionnaire[field]).first
  end

  def extract_explanation(reference, field)
    get_response(reference.questionnaire[field]).second
  end

  def get_response(response)
    response.split(' | ')
  end

  def return_expected_hash(reference)
    {
      'Name' => reference.name,
      'Recruitment cycle year' => 2021,
      'Email_address' => reference.email_address,
      'Guidance rating' => extract_rating(reference, RefereeQuestionnaire::GUIDANCE_QUESTION),
      'Guidance explanation' => extract_explanation(reference, RefereeQuestionnaire::GUIDANCE_QUESTION),
      'Experience rating' => extract_rating(reference, RefereeQuestionnaire::EXPERIENCE_QUESTION),
      'Experience explanation' => extract_explanation(reference, RefereeQuestionnaire::EXPERIENCE_QUESTION),
      'Consent to be contacted' => extract_rating(reference, RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION),
      'Contact details' => extract_explanation(reference, RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION),
    }
  end
end
