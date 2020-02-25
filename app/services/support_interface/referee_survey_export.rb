module SupportInterface
  class RefereeSurveyExport
    def call
      references = ApplicationReference.where.not(questionnaire: nil)
      references_with_feedback = references.reject do |reference|
        reference.questionnaire.values.all? { |response| response == ' | ' }
      end

      output = []
      references_with_feedback.each do |reference|
        hash = {
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

        output << hash
      end

      output
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
  end
end
