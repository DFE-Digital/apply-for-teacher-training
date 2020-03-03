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
      'Guidance rating' => extract_rating(reference, 'Please rate how useful our guidance was'),
      'Guidance explanation' => extract_explanation(reference, 'Please rate how useful our guidance was'),
      'Experience rating' => extract_rating(reference, 'Please rate your experience of giving a reference'),
      'Experience explanation' => extract_explanation(reference, 'Please rate your experience of giving a reference'),
      'Consent to be contacted' => extract_rating(reference, 'Can we contact you about your experience of giving a reference?'),
      'Contact details' => extract_explanation(reference, 'Can we contact you about your experience of giving a reference?'),
      'Safe to work with children?' => extract_rating(reference, 'If we asked whether a candidate was safe to work with children, would you feel able to answer?'),
      'Safe to work with children explanation' => extract_explanation(reference, 'If we asked whether a candidate was safe to work with children, would you feel able to answer?'),
    }
  end
end
