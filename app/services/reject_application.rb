class RejectApplication
  include ActiveModel::Validations

  def initialize(application_choice:, rejection:)
    @application_choice = application_choice
    @rejection = rejection
  end

  def save
    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).reject_application!

      @application_choice.update!(
        rejection_reason: @rejection[:reason],
        rejected_at: @rejection[:timestamp],
      )
    end
  rescue Workflow::NoTransitionAllowed => e
    errors.add(:state, e.message)
    false
  end
end
