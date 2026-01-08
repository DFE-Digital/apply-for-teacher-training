class SupportInterface::QualificationsComponent < BaseComponent
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end
end
