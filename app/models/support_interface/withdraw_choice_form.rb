module SupportInterface
  class WithdrawChoiceForm
    include ActiveModel::Model
    attr_accessor :application_form, :application_choice_id

    def courses_that_can_be_cancelled
      application_form.application_choices.includes(:course, :provider).where(status: %w[awaiting_references application_complete])
    end

    def save
      application_choice = courses_that_can_be_cancelled.find(application_choice_id)
      ApplicationStateChange.new(application_choice).cancel!
      true
    end
  end
end
