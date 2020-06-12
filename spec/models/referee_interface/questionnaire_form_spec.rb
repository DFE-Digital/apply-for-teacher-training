require 'rails_helper'

RSpec.describe RefereeInterface::QuestionnaireForm do
  let(:params) do
    {
      'experience_rating' => 'very_good',
      'experience_explanation_very_poor' => 'should not be returned',
      'experience_explanation_poor' => 'should not be returned',
      'experience_explanation_ok' => 'should not be returned',
      'experience_explanation_good' => 'should not be returned',
      'experience_explanation_very_good' => 'definitely should be returned',
      'guidance_rating' => 'good',
      'guidance_explanation_very_poor' => 'should not be returned',
      'guidance_explanation_poor' => 'should not be returned',
      'guidance_explanation_ok' => 'should not be returned',
      'guidance_explanation_good' => 'definitely should be returned',
      'guidance_explanation_very_good' => 'should not be returned',
      'consent_to_be_contacted' => 'true',
      'consent_to_be_contacted_details' => 'anytime 012345 678900',
    }
  end

  let(:correct_params) do
    {
      RefereeQuestionnaire::EXPERIENCE_QUESTION => 'very_good | definitely should be returned',
      RefereeQuestionnaire::GUIDANCE_QUESTION => 'good | definitely should be returned',
      RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => 'true | anytime 012345 678900',
    }
  end

  let(:reference) { create(:reference) }

  describe '#save' do
    it 'updates the questionnaire for a reference' do
      described_class.new(params).save(reference)
      expect(reference.questionnaire).to eq(correct_params)
    end

    it 'updates the consent to be contacted for a reference' do
      described_class.new(params).save(reference)
      expect(reference.consent_to_be_contacted).to eq(true)
    end
  end
end
