class SupportInterface::QualificationsComponent < ApplicationComponent
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end
end
