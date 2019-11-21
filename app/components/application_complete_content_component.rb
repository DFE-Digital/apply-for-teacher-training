class ApplicationCompleteContentComponent < ActionView::Component::Base
  include ViewHelper

  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
    @dates = ApplicationDates.new(@application_form)
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

private

  attr_reader :application_form
end
