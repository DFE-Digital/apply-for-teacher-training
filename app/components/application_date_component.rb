class ApplicationDateComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:, type:)
    @application_form = application_form
    @type = type
    @dates = ApplicationDates.new(@application_form)
  end

  def submitted_at_date
    @dates.submitted_at.strftime('%e %B %Y')
  end

  def respond_by_date
    @dates.respond_by.strftime('%e %B %Y')
  end

  def edit_by_date
    @dates.edit_by.strftime('%e %B %Y')
  end

  def formatted_days_remaining
    pluralize(@dates.days_remaining_to_edit, 'day')
  end

private

  attr_reader :application_form, :type
end
