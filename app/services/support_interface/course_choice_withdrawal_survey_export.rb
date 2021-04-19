module SupportInterface
  class CourseChoiceWithdrawalSurveyExport
    def data_for_export
      application_choices.find_each(batch_size: 100).map do |application_choice|
        survey = application_choice.withdrawal_feedback
        {
          full_name: application_choice.application_form.full_name,
          explanation: survey['Explanation'],
          contact_details: survey['Contact details'],
          reason_for_withdrawing: survey['Do you have a reason for withdrawing?'],
          consent_to_be_contacted: survey['Can we contact you about your experience of using this service?'],
        }
      end
    end

  private

    def application_choices
      ApplicationChoice.where.not(withdrawal_feedback: nil).includes(:application_form)
    end
  end
end
