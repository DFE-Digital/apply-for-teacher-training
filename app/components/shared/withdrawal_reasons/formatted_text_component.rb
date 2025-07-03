class WithdrawalReasons::FormattedTextComponent < ViewComponent::Base
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def render?
    @application_choice.withdrawn?
  end

  def call
    govuk_list(reasons)
  end

# private

  # def reasons
  #   @application_choice.published_withdrawal_reasons.map do |reason|
  #     reason.reason (translated)

  #     if reason ends with .other comment also needs to be appended

  #     .flatten
  #   end
  #  end
  # put yml file in same path in config - matching file structure
end
