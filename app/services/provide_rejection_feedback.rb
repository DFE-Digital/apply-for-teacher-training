class ProvideRejectionFeedback
  def initialize(application_choice, helpful)
    @application_choice = application_choice
    @helpful = helpful
  end

  def call
    return unless application_choice.rejected?

    RejectionFeedback.create(application_choice:, helpful:)
  end

private

  attr_reader :application_choice, :helpful
end
