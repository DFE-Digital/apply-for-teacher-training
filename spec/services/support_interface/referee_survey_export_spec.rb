require 'rails_helper'

RSpec.describe SupportInterface::RefereeSurveyExport do
  describe '#call' do
    let(:questionnaire1) do
      {
        'Please rate how useful our guidance was' => "very_poor | I couldn't read it.",
        'Please rate your experience of giving a reference' => 'very_good | I could read it.',
        'Can we contact you about your experience of giving a reference?' => 'yes | 02113131',
        'If we asked whether a candidate was safe to work with children, would you feel able to answer?' => 'yes | ',
      }
    end

    let(:questionnaire2) do
      {
        'Please rate how useful our guidance was' => 'good | ',
        'Please rate your experience of giving a reference' => 'poor | ',
        'Can we contact you about your experience of giving a reference?' => ' | ',
        'If we asked whether a candidate was safe to work with children, would you feel able to answer?' => ' | ',
      }
    end

    let(:questionnaire3) do
      {
        'Please rate how useful our guidance was' => ' | ',
        'Please rate your experience of giving a reference' => ' | ',
        'Can we contact you about your experience of giving a reference?' => ' | ',
        'If we asked whether a candidate was safe to work with children, would you feel able to answer?' => ' | ',
      }
    end

    it 'returns a hash of referees responses' do
      reference1 = create(:reference, questionnaire: questionnaire1)
      reference2 = create(:reference, questionnaire: questionnaire2)
      create(:reference, questionnaire: questionnaire3)

      reference1_response = {
        'Name' => reference1.name,
        'Email_address' => reference1.email_address,
        'Guidance rating' => reference1.questionnaire.values.first.split(' | ').first,
        'Guidance explanation' => reference1.questionnaire.values.first.split(' | ').second,
        'Experience rating' => reference1.questionnaire.values.second.split(' | ').first,
        'Experience explanation' => reference1.questionnaire.values.second.split(' | ').second,
        'Consent to be contacted' => reference1.questionnaire.values.third.split(' | ').first,
        'Contact details' => reference1.questionnaire.values.third.split(' | ').second,
        'Safe to work with children?' => reference1.questionnaire.values.fourth.split(' | ').first,
        'Safe to work with children explanation' => reference1.questionnaire.values.fourth.split(' | ').second,
      }

      reference2_response = {
      'Name' => reference2.name,
      'Email_address' => reference2.email_address,
      'Guidance rating' => reference2.questionnaire.values.first.split(' | ').first,
      'Guidance explanation' => reference2.questionnaire.values.first.split(' | ').second,
      'Experience rating' => reference2.questionnaire.values.second.split(' | ').first,
      'Experience explanation' => reference2.questionnaire.values.second.split(' | ').second,
      'Consent to be contacted' => reference2.questionnaire.values.third.split(' | ').first,
      'Contact details' => reference2.questionnaire.values.third.split(' | ').second,
      'Safe to work with children?' => reference2.questionnaire.values.fourth.split(' | ').first,
      'Safe to work with children explanation' => reference2.questionnaire.values.fourth.split(' | ').second,
    }

      expect(described_class.call).to eq [reference1_response, reference2_response]
    end
  end
end
