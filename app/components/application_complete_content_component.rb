class ApplicationCompleteContentComponent < ActionView::Component::Base
  include ViewHelper

  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
    @dates = ApplicationDates.new(@application_form)
  end

  def any_accepted_offer?
    @application_form.application_choices.map.any?(&:pending_conditions?)
  end

  def all_provider_decisions_made?
    @application_form.application_choices.any? &&
      @application_form.application_choices.where(status: %w[awaiting_references application_complete awaiting_provider_decision]).empty?
  end

  def any_awaiting_provider_decision?
    @application_form.application_choices.map.any?(&:awaiting_provider_decision?)
  end

  def any_offers?
    @application_form.application_choices.map.any?(&:offer?)
  end

  def editable?
    @dates.form_open_to_editing?
  end

  def decline_by_default_remaining_days
    distance_in_days = (@dates.decline_by_default_at.to_date - Date.current).to_i

    [0, distance_in_days].max
  end

  def decline_by_default_date
    @dates.decline_by_default_at.strftime('%-e %B %Y')
  end

private

  attr_reader :application_form
end
