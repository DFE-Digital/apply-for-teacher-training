module SupportInterface
  class RefereeSurveyExport
    def self.call
      references = ApplicationReference.where.not(questionnaire: nil)
      references_with_feedback = references.reject do |reference|
        reference.questionnaire.values.all? { |response| response == ' | ' }
      end

      output = []
      references_with_feedback.each do |reference|
        hash = {
          'Name' => reference.name,
          'Email_address' => reference.email_address,
          'Guidance rating' => reference.questionnaire.values.first.split(' | ').first,
          'Guidance explanation' => reference.questionnaire.values.first.split(' | ').second,
          'Experience rating' => reference.questionnaire.values.second.split(' | ').first,
          'Experience explanation' => reference.questionnaire.values.second.split(' | ').second,
          'Consent to be contacted' => reference.questionnaire.values.third.split(' | ').first,
          'Contact details' => reference.questionnaire.values.third.split(' | ').second,
          'Safe to work with children?' => reference.questionnaire.values.fourth.split(' | ').first,
          'Safe to work with children explanation' => reference.questionnaire.values.fourth.split(' | ').second,
        }

        output << hash
      end

      output
    end
  end
end
