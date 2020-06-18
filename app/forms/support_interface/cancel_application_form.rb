module SupportInterface
  class CancelApplicationForm
    include ActiveModel::Model

    attr_accessor :application_form

    def save!
      application_form.application_choices.includes(:course_option).where(status: %w[awaiting_references application_complete]).find_each do |application_choice|
        ApplicationStateChange.new(application_choice).cancel!
      end

      application_form.application_references.feedback_requested.each do |reference|
        CancelReferee.new.call(reference: reference)
      end
    end
  end
end
