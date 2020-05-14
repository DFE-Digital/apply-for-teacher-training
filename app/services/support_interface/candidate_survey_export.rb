module SupportInterface
  class CandidateSurveyExport
    def call
      application_forms = ApplicationForm.where.not(satisfaction_survey: nil)

      output = []

      application_forms.includes(:candidate).each do |application_form|
        survey = application_form.satisfaction_survey

        survey_fields = SatisfactionSurvey::QUESTIONS_WE_ASK
          .index_with { |question| survey[question] }

        answer = {
          'Name' => application_form.full_name,
          'Email_address' => application_form.candidate.email_address,
          'Phone number' => application_form.phone_number,
        }.merge(survey_fields)

        output << answer
      end

      output
    end
  end
end
