class SummaryCardHeaderComponent < ViewComponent::Base
  POSSIBLE_CHECK_ICON_VALUES = [true, false, 'true', 'false'].freeze

  def initialize(title:, heading_level: 2, check_icon: false)
    argument_guard(check_icon)
    @title = title
    @heading_level = heading_level
    @check_icon = ActiveModel::Type::Boolean.new.cast(check_icon)
  end

private

  def argument_guard(check_icon)
    check = POSSIBLE_CHECK_ICON_VALUES.include?(check_icon)
    raise ArgumentError.new('check_icon must be a boolean, "true" or "false" strings') unless check
  end
end
