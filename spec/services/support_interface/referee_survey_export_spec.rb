require 'rails_helper'

RSpec.describe SupportInterface::RefereeSurveyExport do
  describe '#call' do
    let(:questionnaire1) do
      {
        RefereeQuestionnaire::GUIDANCE_QUESTION => "very_poor | I couldn't read it.",
        RefereeQuestionnaire::EXPERIENCE_QUESTION => 'very_good | I could read it.',
        RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => 'yes | 02113131',
        RefereeQuestionnaire::SAFE_TO_WORK_WITH_CHILDREN_QUESTION => 'yes | ',
      }
    end

    let(:questionnaire2) do
      {
        RefereeQuestionnaire::GUIDANCE_QUESTION => 'good | ',
        RefereeQuestionnaire::EXPERIENCE_QUESTION => 'poor | ',
        RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => ' | ',
        RefereeQuestionnaire::SAFE_TO_WORK_WITH_CHILDREN_QUESTION => ' | ',
      }
    end

    let(:questionnaire3) do
      {
        RefereeQuestionnaire::GUIDANCE_QUESTION => ' | ',
        RefereeQuestionnaire::EXPERIENCE_QUESTION => ' | ',
        RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => ' | ',
        RefereeQuestionnaire::SAFE_TO_WORK_WITH_CHILDREN_QUESTION => ' | ',
      }
    end

    it 'returns a hash of referees responses' do
      reference1 = create(:reference, questionnaire: questionnaire1)
      reference2 = create(:reference, questionnaire: questionnaire2)
      create(:reference, questionnaire: questionnaire3)

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
      'Email_address' => reference.email_address,
      'Guidance rating' => extract_rating(reference, RefereeQuestionnaire::GUIDANCE_QUESTION),
      'Guidance explanation' => extract_explanation(reference, RefereeQuestionnaire::GUIDANCE_QUESTION),
      'Experience rating' => extract_rating(reference, RefereeQuestionnaire::EXPERIENCE_QUESTION),
      'Experience explanation' => extract_explanation(reference, RefereeQuestionnaire::EXPERIENCE_QUESTION),
      'Consent to be contacted' => extract_rating(reference, RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION),
      'Contact details' => extract_explanation(reference, RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION),
      'Safe to work with children?' => extract_rating(reference, RefereeQuestionnaire::SAFE_TO_WORK_WITH_CHILDREN_QUESTION),
      'Safe to work with children explanation' => extract_explanation(reference, RefereeQuestionnaire::SAFE_TO_WORK_WITH_CHILDREN_QUESTION),
    }
  end
end
