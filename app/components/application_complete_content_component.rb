class ApplicationCompleteContentComponent < ActionView::Component::Base
  include ViewHelper

  validates :submitted_at, presence: true

  def initialize(submitted_at:)
    @submitted_at = submitted_at
  end

  def submitted_at_date
    @submitted_at.strftime('%e %B %Y')
  end

  def respond_by_date
    (@submitted_at + 40.days).strftime('%e %B %Y')
  end

  def edit_by_date
    (@submitted_at + 7.days).strftime('%e %B %Y')
  end

  def days_remaining_to_edit
    (@submitted_at.to_date + 7.days - Time.now.to_date).to_i
  end

  def formatted_days_remaining
    days_remaining_to_edit == 1 ? '1 day' : "#{days_remaining_to_edit} days"
  end

private

  attr_reader :submitted_at
end
