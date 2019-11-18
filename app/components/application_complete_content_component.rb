class ApplicationCompleteContentComponent < ActionView::Component::Base
  include ViewHelper

  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
    @dates = ApplicationDates.new(@application_form)
  end

private

  attr_reader :application_form
end
