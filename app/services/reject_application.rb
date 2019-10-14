class RejectApplication
  attr_reader :rejection_reason

  include ActiveModel::Validations

  validates_presence_of :rejection_reason
  validates_length_of :rejection_reason, maximum: 255

  def initialize(application_choice:, rejection_reason:)
    @application_choice = application_choice
    @rejection_reason = rejection_reason
  end

  def save
    return unless valid?

    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).reject_application!

      @application_choice.update!(
        rejection_reason: @rejection_reason,
      )
    end
  rescue Workflow::NoTransitionAllowed => e
    errors.add(:state, e.message)
    false
  end
end
