require 'rails_helper'

RSpec.describe RefereeInterface::ReferenceQuestionnaireForm do
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
      'safe_to_work_with_children' => 'false',
      'safe_to_work_with_children_explanation' => 'This should show',
      'consent_to_be_contacted' => 'true',
      'consent_to_be_contacted_details' => 'anytime 012345 678900',
    }
  end

  let(:correct_params) do
    {
      'experience_rating' => 'very_good',
      'experience_explanation' => 'definitely should be returned',
      'guidance_rating' => 'good',
      'guidance_explanation' => 'definitely should be returned',
      'safe_to_work_with_children' => 'false',
      'safe_to_work_with_children_explanation' => 'This should show',
      'consent_to_be_contacted' => 'true',
      'consent_to_be_contacted_details' => 'anytime 012345 678900',
    }
  end

  let(:reference) { create(:reference) }

  describe '#extract_parameters' do
    it 'returns a hash with the correct values' do
      expect(described_class.new(reference: reference, parameters: params).extract_parameters).to eq correct_params
    end
  end

  describe '#save' do
    it 'updates the questionnaire' do
      described_class.new(reference: reference, parameters: params).save
      expect(reference.questionnaire).to eq(correct_params)
    end

    it 'updates the consent_to_be_contacted' do
      described_class.new(reference: reference, parameters: params).save
      expect(reference.consent_to_be_contacted).to eq(true)
    end
  end
end
