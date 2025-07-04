class WithdrawalReasons::FormattedTextComponent < ViewComponent::Base
  OLD_REASONS_PATH = 'config/withdrawal_reasons.yml'.freeze

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def render?
    @application_choice.withdrawn?
  end

  def call
    govuk_list(reasons)
  end

private

  def reasons; end
