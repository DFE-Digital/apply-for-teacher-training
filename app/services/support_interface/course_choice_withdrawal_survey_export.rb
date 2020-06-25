module SupportInterface
  class CourseChoiceWithdrawalSurveyExport
    def self.call
      application_choices = ApplicationChoice.where.not(withdrawal_feedback: nil)

      output = []

      application_choices.includes(:application_form).each do |application_choice|
        survey = application_choice.withdrawal_feedback

        answer = {
          'Name' => application_choice.application_form.full_name,
        }.merge(survey)

        output << answer
      end

      output
    end
  end
end
